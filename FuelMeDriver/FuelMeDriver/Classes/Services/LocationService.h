//
//  LocationService.h
//  FuelMe
//
//  Created by Tyson Bunch on 1/31/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

#import "RARideDataModel.h"
#import "RideDriverEnums.h"

typedef void(^MaxProximityReachedBlock)(void);
typedef void(^LocationHasChangedBlock)(CLLocationCoordinate2D newLocation);

@protocol LocationUpdateDelegate <NSObject>

/**
 *  @brief called when carIcon has new coordinate and direction
 */
- (void)locationUpdateCarIconCoordinate:(CLLocationCoordinate2D)coordinate andDirection:(CLLocationDirection)direction;
/**
 *  @brief called when the user has whenInUse mode
 */
- (void)notifyUserToChangeAuthorizationToAlways;

@end

@interface LocationService : NSObject<CLLocationManagerDelegate>

@property(nonatomic, weak) id <LocationUpdateDelegate>delegate;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *myLocation;

+ (LocationService*)sharedService;
- (void)start;
- (void)stop;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)checkIfNeedToNotifyChangeOfAuthorizationToAlways;

/**
 *  @brief executes block when location has changed in the meters passed (comparing coordinates distances).
 */
- (void)notifyIfLocationChangesIn:(float)meters withCompletion:(LocationHasChangedBlock)handler;
- (void)cancelLocationChangedObservers;

/**
 *  @param completion is called when @b maxProximityMeters to @b destination is met
 */
- (void)observeIfProximity:(float)maxProximityMeters to:(CLLocation *)destination reachedWithCompletion:(MaxProximityReachedBlock)completion;
- (BOOL)isAllowedToPressArrivedBasedOnPickup:(CLLocation* ) pickUpLocation;
- (void)cancelProximityObservers;

#pragma mark - Helper functions

+ (BOOL)isCoordinateValidForRide:(CLLocationCoordinate2D)coordinate;
+ (BOOL)hasLocationAuthorization;

@end
