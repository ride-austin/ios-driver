//
//  LocationService.m
//  FuelMe
//
//  Created by Tyson Bunch on 1/31/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import "LocationService.h"

#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>

#import "CLLocation+validation.h"
#import "ConfigurationManager.h"
#import "ErrorReporter.h"
#import "LocationViewController.h"
#import "NSDate+Utils.h"
#import "PersistenceManager.h"
#import "RACarCategoryDataModel+Collections.h"
#import "RARideCacheManager.h"
#import "RideDriverConstants.h"
@import Firebase;

static CGFloat const kFilterAccuracy = 70;
static CGFloat const kFilterTime     = 0.25;
static CLLocationDistance const kFilterDistance = 2; // in meters

@interface LocationService ()

@property (nonatomic) NSOperationQueue *updateLocationQueue;
@property (nonatomic) NSDate *lastTimeLocationUpdated;
@property (nonatomic) CLLocation *previousLocation;

//Proximity Observers
@property (nonatomic) float maxProximityMeters;
@property (nonatomic) CLLocation *trackedProximityToLocation;
@property (nonatomic) BOOL needsToNotifyMaxProximityReached;
@property (nonatomic, copy) MaxProximityReachedBlock maxProximityReachedBlock;

//Meters Observer
@property (nonatomic) float movedMeters;
@property (nonatomic) CLLocation *trackedMetersToLocation;
@property (nonatomic) BOOL needsToNotifyLocationChangedByMeters;
@property (nonatomic, copy) LocationHasChangedBlock trackedLocationHasChangedBlock;

@end

@implementation LocationService

+ (LocationService*)sharedService {
    static LocationService *locationService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationService = [[self alloc] init];
    });
    return locationService;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        [self configureLocationManager];
        
        [self addNotificationObservers];
        
        self.updateLocationQueue = [NSOperationQueue new];
        self.updateLocationQueue.maxConcurrentOperationCount = 1;
        self.updateLocationQueue.qualityOfService = NSQualityOfServiceUtility;
        
        self.movedMeters = 0;
        self.needsToNotifyLocationChangedByMeters = NO;
        self.needsToNotifyMaxProximityReached = NO;
    }
    return self;
}

- (void)configureLocationManager {
    [self.locationManager requestAlwaysAuthorization];
    
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kFilterDistance;
    self.locationManager.desiredAccuracy = [LocationService accuracyByDriverState];
    self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
}

- (void)setLocationManager:(CLLocationManager *)locationManager {
    _locationManager = locationManager;
    [self configureLocationManager];
}

#pragma mark - Notification Observers

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foreground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(driverStateChanged:)
                                                 name:kDriverStateChangeNotification
                                               object:nil];
}

- (void)foreground:(NSNotification*)notification {
    if ([RASessionManager shared].isSignedIn) {
        [self start];
    }
}

- (void)driverStateChanged:(NSNotification *)notification {
    self.locationManager.desiredAccuracy = [LocationService accuracyByDriverState];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(forceUpdateLocation) object:nil];
    if ([DriverManager shared].driverState == AvailableDriverState) {
        [self performSelector:@selector(forceUpdateLocation) withObject:nil afterDelay:[self forceUpdateInterval]];
    }
}

#pragma mark - Methods

- (void)start {
    DBLog(@"START TRACKING: TIMESTAMP: %@", [[NSDate new] convertToStringUsingFormat:@"hh:mm:ss"]);
    [self.locationManager startUpdatingLocation];
}

- (void)stop {
    DBLog(@"STOP TRACKING: TIMESTAMP: %@", [[NSDate new] convertToStringUsingFormat:@"hh:mm:ss"]);
    [self.locationManager stopUpdatingLocation];
    [self stopMonitoring];
}

- (void)startMonitoring {
    [self stopMonitoring];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitoring {
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)checkIfNeedToNotifyChangeOfAuthorizationToAlways {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (self.delegate){
            [self.delegate notifyUserToChangeAuthorizationToAlways];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DBLog(@"Error in location: %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self logStatus:status];
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusNotDetermined:
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [ConfigurationManager needsReload];
            break;
    }
}

- (void)logStatus:(CLAuthorizationStatus)status {
    [Bugfender setDeviceString:[self stringForStatus:status] forKey:@"CLAuthorizationStatus"];
}

- (NSString *)stringForStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied:
            return @"Denied";
        case kCLAuthorizationStatusRestricted:
            return @"Restricted";
        case kCLAuthorizationStatusNotDetermined:
            return @"NotDetermined";
        case kCLAuthorizationStatusAuthorizedAlways:
            return @"Always";
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return @"WhenInUse";
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];

    if (self.myLocation) {
        NSTimeInterval timeSince = fabs([self.myLocation.timestamp timeIntervalSinceNow]);
        BOOL hasRecentUpdate = timeSince < kFilterTime;
        BOOL invalidAccuracyNegative = newLocation.horizontalAccuracy < 0;
        BOOL invalidAccuracyTooLow   = newLocation.horizontalAccuracy > kFilterAccuracy;
        BOOL invalidData     =  invalidAccuracyTooLow || invalidAccuracyNegative;
        
        [self recordAccuracy:newLocation.horizontalAccuracy isRejected:invalidAccuracyTooLow];
        if (invalidData || hasRecentUpdate){
            return;
        }
    }
    
    //update my location
    self.previousLocation = self.myLocation;
    self.myLocation = newLocation;
    [self updateDriverPosition];
    [self checkProximityBasedOnLocation:newLocation];
    [self checkLocationChangedByMeterBasedOnLocation:newLocation];
    [ConfigurationManager checkConfigurationBasedOnLocation:newLocation];
}

/**
 *  @brief RA-3210 Record ontrip horizontal accuracy just recording if checking accuracy is useful
 */
- (void)recordAccuracy:(double)horizontalAccuracy isRejected:(BOOL)invalidAccuracyTooLow {
    if ([DriverManager shared].driverState == OnTripDriverState) {
        int x = 10;
        int nearestX = floor(horizontalAccuracy/x + 0.5) * x;
        NSNumber *accuracy = @((int)nearestX);
        if (invalidAccuracyTooLow) {
            [FIRAnalytics logEventWithName:@"Location Accuracy Event"
                                parameters:@{@"invalidAccuracy10s":accuracy}];
        }
        
        [FIRAnalytics logEventWithName:@"Location Accuracy Event"
                            parameters:@{@"All Ontrip Horizontal Accuracies":accuracy}];
    }
}

- (void)checkProximityBasedOnLocation:(CLLocation *)newLocation {
    if (self.needsToNotifyMaxProximityReached) {
        CLLocationDistance distance = [self.trackedProximityToLocation distanceFromLocation:newLocation];
        if (distance <= self.maxProximityMeters) {
            self.needsToNotifyMaxProximityReached = NO;
            self.maxProximityMeters = 0;
            if (self.maxProximityReachedBlock) {
                self.maxProximityReachedBlock();
            }
        }
    }
}

- (BOOL)isAllowedToPressArrivedBasedOnPickup:(CLLocation* ) pickUpLocation {
    if ([[LocationService sharedService].myLocation isValid]) {
        CLLocationDistance distance = [self.myLocation distanceFromLocation:pickUpLocation];
        double allowedDistance = [[ConfigurationManager shared].global.driverActions.allowArriveDistanceToPickup doubleValue];
        if (distance <= allowedDistance || [ConfigurationManager shared].global.driverActions.allowArriveDistanceToPickup == nil) {
            return YES;
        }
        else {
            return NO;
        }
    }
    return YES;
}

- (void)checkLocationChangedByMeterBasedOnLocation:(CLLocation *)newLocation {
    if (self.needsToNotifyLocationChangedByMeters) {
        if (!self.trackedMetersToLocation) {
            self.trackedMetersToLocation = self.myLocation;
        }
        CLLocationDistance distance = [self.trackedMetersToLocation distanceFromLocation:newLocation];
        if (distance >= self.movedMeters) {
            self.needsToNotifyLocationChangedByMeters = NO;
            self.movedMeters = 0;
            
            if (self.trackedLocationHasChangedBlock) {
                self.trackedLocationHasChangedBlock(newLocation.coordinate);
            }
        }
    }
}

/**
 *  @return NO if location has been updated or recorded recently within the 'diff' amount of time
 */
- (BOOL)doesLocationNeedRecording {
    NSDate *lastTime = self.lastTimeLocationUpdated;
    if (self.lastTimeLocationUpdated) {
        
        NSTimeInterval diff = [[NSDate trueDate] timeIntervalSinceDate:lastTime];
        
        ConfigLocationUpdateIntervals *config = [ConfigurationManager shared].global.locationUpdateIntervals;
        switch ([DriverManager shared].driverState) {
            case GoingToPickUpDriverState:
            case ArrivingToPickUpDriverState:
            case OnTripDriverState: {
                // The driver is in a ride i.e. from the DRIVER_ASSIGNED to the COMPLETED state
                if (diff <= config.whenOnTrip.doubleValue) {
                    return NO;
                }
            }
                break;
                
            case AvailableDriverState:
            case InvalidDriverState:
            case OfflineDriverState: {
                
                if (!self.myLocation) {
                    return NO;
                } else {
                    CLLocationSpeed speed = self.myLocation.speed;
                    if (speed < 0 && self.previousLocation) {
                        CLLocationDistance distance = [self.previousLocation distanceFromLocation:self.myLocation];
                        NSTimeInterval time = [self.myLocation.timestamp timeIntervalSinceDate:self.previousLocation.timestamp];
                        if (time > 0) {
                            speed = distance / time;
                        }
                        self.previousLocation = nil;
                    }
                    
                    if (speed > config.movementSpeed.doubleValue) {
                        // The driver is not in a ride and the driver is moving
                        if (diff <= config.whenOnlineAndMoving.doubleValue) {
                            return NO;
                        }
                    } else {
                        // The driver is not in a ride and the driver is stationary
                        if (diff <= config.whenOnlineAndNotMoving.doubleValue) {
                            return NO;
                        }
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }
    self.lastTimeLocationUpdated = [NSDate trueDate];
    return YES;
}

- (void)updateDriverPosition {
    CLLocation *currentLocation = self.myLocation;
    
    //Avoid Invalid Location
    if (!currentLocation.isValid) {
        return;
    }
    
    //Notify delegate to update UI
    [self.delegate locationUpdateCarIconCoordinate:currentLocation.coordinate andDirection:currentLocation.course];
    
    //Send Location to server if needed
    if ([self doesLocationNeedRecording]) {
        [self.updateLocationQueue addOperationWithBlock:^{
            [[DriverManager shared] updateCoordinate:currentLocation.coordinate course:currentLocation.course speed:currentLocation.speed withCompletion:^(NSError * _Nullable error) {}];
        }];
    }
}

#pragma mark - Force Update Location

- (NSTimeInterval)forceUpdateInterval {
    return [[ConfigurationManager shared].global.locationUpdateIntervals.whenOnlineAndNotMoving doubleValue];
}

- (void)forceUpdateLocation {
    if ([DriverManager shared].driverState == AvailableDriverState) {
        [self updateDriverPosition];
        [self performSelector:@selector(forceUpdateLocation) withObject:nil afterDelay:[self forceUpdateInterval]];
    }
}

#pragma mark - Location Observers

- (void)notifyIfLocationChangesIn:(float)meters withCompletion:(LocationHasChangedBlock)handler {
    self.movedMeters = meters;
    self.needsToNotifyLocationChangedByMeters = YES;
    self.trackedMetersToLocation = self.myLocation;
    self.trackedLocationHasChangedBlock = handler;
}

- (void)observeIfProximity:(float)maxProximityMeters to:(CLLocation *)destination reachedWithCompletion:(MaxProximityReachedBlock)completion {
    self.maxProximityReachedBlock = completion;
    self.maxProximityMeters = maxProximityMeters;
    self.needsToNotifyMaxProximityReached = YES;
    self.trackedProximityToLocation = destination;
    
    if ([[LocationService sharedService].myLocation isValid]) {
        [self checkProximityBasedOnLocation:[LocationService sharedService].myLocation];
    }
}

- (void)cancelProximityObservers {
    self.trackedProximityToLocation = nil;
    self.maxProximityMeters = 0;
    self.maxProximityReachedBlock = nil;
    self.needsToNotifyMaxProximityReached = NO;
}

- (void)cancelLocationChangedObservers {
    self.movedMeters = 0;
    self.trackedMetersToLocation = nil;
    self.trackedLocationHasChangedBlock = nil;
    self.needsToNotifyLocationChangedByMeters = NO;
}

#pragma mark - Helper functions

+ (BOOL)isCoordinateValidForRide:(CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DIsValid(coordinate) && coordinate.longitude != 0 && coordinate.latitude != 0;
}

+ (BOOL)hasLocationAuthorization {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return [CLLocationManager locationServicesEnabled] && (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse);
}

+ (CLLocationAccuracy)accuracyByDriverState {
    switch ([DriverManager shared].driverState) {
        case OfflineDriverState:
            return kCLLocationAccuracyThreeKilometers;
        case AvailableDriverState:
            return kCLLocationAccuracyNearestTenMeters;
        case ArrivingToPickUpDriverState:
        case GoingToPickUpDriverState:
        case OnTripDriverState:
            return kCLLocationAccuracyBestForNavigation;
        default:
            return kCLLocationAccuracyThreeKilometers;
            break;
    }
}

@end
