//
//  CLLocationManagerMock.m
//  RideDriver
//
//  Created by Roberto Abreu on 8/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "CLLocationManagerMock.h"

#import "DriverManager.h"
#import "LocationService.h"
#import "RideDriverConstants.h"
#import "RideDriverEnums.h"

#define kDefaultAltitude 0
#define kDefaultHorizontalAccuracy 50
#define kDefaultVerticalAccuracy 50
#define kDefaultLocationUpdateInterval 1

@interface CLLocationManagerMock ()

@property (strong, nonatomic) NSMutableArray<CLLocation*> *locations;
@property (assign, nonatomic) NSInteger currentLocationIndex;

@end

@implementation CLLocationManagerMock

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        self.locations = [[NSMutableArray alloc] init];
        self.defaultLocation = [[CLLocation alloc] initWithLatitude:30.4172743 longitude:-97.7501108];
        [self addObservers];
    }
    return self;
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(driverStateChanged:) name:kDriverStateChangeNotification object:nil];
}

- (void)driverStateChanged:(NSNotification *)notification {
    DriverState state = (DriverState)[notification.object[kDriverStateChangeNotification] integerValue];
    [self reloadLocationsByDriverState:state];
    [self sendLocationUpdate];
}

- (void)reloadLocationsByDriverState:(DriverState)state {
    NSAssert(self.locationStateMapping, @"Location State Mapping must be defined");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendLocationUpdate) object:nil];
    
    @synchronized (self) {
        self.currentLocationIndex = 0;
        [self.locations removeAllObjects];
        NSString *fileMappingName = self.locationStateMapping[@(state)];
        if (fileMappingName) {
            NSString *path = [[NSBundle mainBundle] pathForResource:fileMappingName ofType:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            
            NSError *error;
            NSArray<NSDictionary*> *locationsDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSAssert(!error, @"An error occur while parsing mapping file : %@", error.localizedDescription);
            
            [self parseFileContent:locationsDict];
        }
    }

}

- (void)parseFileContent:(NSArray<NSDictionary*>*)locationsDict {
    
    for (NSDictionary *locationDict in locationsDict) {
        double lat = [locationDict[@"latitude"] doubleValue];
        double lng = [locationDict[@"longitude"] doubleValue];
        double course = [locationDict[@"course"] doubleValue];
        double speed = [locationDict[@"speed"] doubleValue];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lng);
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:kDefaultAltitude horizontalAccuracy:kDefaultHorizontalAccuracy verticalAccuracy:kDefaultVerticalAccuracy course:course speed:speed timestamp:[NSDate distantFuture]];
        [self.locations addObject:location];
    }

}

#pragma mark - Override Methods

- (void)startUpdatingLocation {
    DBLog(@"Mock Location Update");
    
    [self reloadLocationsByDriverState:[DriverManager shared].driverState];
    [self sendLocationUpdate];
}

- (void)stopUpdatingLocation {
    DBLog(@"Mock Stop Updating Location");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendLocationUpdate) object:nil];
}

- (void)startUpdatingHeading {
    DBLog(@"Mock Start Heading");
}

- (void)stopUpdatingHeading {
    DBLog(@"Mock Stop Heading");
}

#pragma mark - Report Locations Update

- (void)sendLocationUpdate {
    @synchronized (self) {
        
        //If there is not locations to update
        //Use default location
        if (!self.locations || self.locations.count == 0) {
            [self.delegate locationManager:self didUpdateLocations:@[self.defaultLocation]];
            [self performSelector:@selector(sendLocationUpdate) withObject:nil afterDelay:kDefaultLocationUpdateInterval];
            return;
        }
        
        CLLocation *currentLocation;
        if (self.currentLocationIndex < self.locations.count) {
            currentLocation = self.locations[self.currentLocationIndex];
            self.currentLocationIndex++;
        } else {
            currentLocation = [self.locations lastObject];
        }
    
        [self.delegate locationManager:self didUpdateLocations:@[currentLocation]];
        [self performSelector:@selector(sendLocationUpdate) withObject:nil afterDelay:currentLocation.speed];
    }
}

@end
