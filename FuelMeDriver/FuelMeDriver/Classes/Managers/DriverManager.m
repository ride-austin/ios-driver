//
//  DriverManager.m
//  RideDriver
//
//  Created by Carlos Alcala on 9/13/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "DriverManager.h"

#import "ConfigurationManager.h"
#import "ErrorReporter.h"
#import "LocationService.h"
#import "NSString+Ride.h"
#import "NetworkManager.h"
#import "PersistenceManager.h"
#import "RACarCategoryDataModel+Collections.h"
#import "RARideAPI.h"
#import "RARideCacheManager.h"
#import "RideDriver-Swift.h"
#import "RideDriverConstants.h"
#import "SoundManager.h"
#import <FirebaseAnalytics/FirebaseAnalytics.h>

@interface DriverManager()

@property (nonatomic, readwrite) DriverState driverState;

@end

@implementation DriverManager

- (id)init {
    if (self = [super init]) {
        _driverState = OfflineDriverState;
    }
    return self;
}

+ (DriverManager*)shared {
    static DriverManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

+ (DriverState)driverStateBasedOnStatus:(NSString *)status {
    if ([status isEqualToString:@"REQUESTED"]) {
        return AvailableDriverState;
    } else if ([status isEqualToString:@"RIDER_CANCELLED"]) {
        return AvailableDriverState;
    } else if ([status isEqualToString:@"DRIVER_ASSIGNED"]) {
        return GoingToPickUpDriverState;
    } else if ([status isEqualToString:@"DRIVER_CANCELLED"]) {
        return AvailableDriverState;
    } else if ([status isEqualToString:@"DRIVER_REACHED"]) {
        return ArrivingToPickUpDriverState;
    } else if ([status isEqualToString:@"ACTIVE"]) {
        return OnTripDriverState;
    } else if ([status isEqualToString:@"NO_AVAILABLE_DRIVER"]) {
        return AvailableDriverState;
    } else if ([status isEqualToString:@"COMPLETED"]) {
        return AvailableDriverState;
    } else if ([status isEqualToString:@"ADMIN_CANCELLED"]) {
        return OfflineDriverState;
    } else if ([status isEqualToString:@"AVAILABLE"]) {
        return AvailableDriverState;
    } else if ([status isEqualToString:@"RIDING"]) {
        return OnTripDriverState;
    } else if ([status isEqualToString:@"INACTIVE"]) {
        return OfflineDriverState;
    }
    return InvalidDriverState;
}

- (void)setDriverState:(DriverState)driverState {
    DriverState previousState = _driverState;
    BFLog(@"setDriverState from %@ to %@",[NSString driverStateToString:previousState], [NSString driverStateToString:driverState]);
    _driverState = driverState;
    [PersistenceManager saveDriverState:driverState];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.driverState] forKey:kDriverStateChangeNotification];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDriverStateChangeNotification object:userInfo];
    [self playSoundForPrevious:previousState toCurrent:driverState];
    if (self.delegate) {
        [self.delegate driverManagerDidUpdateDriverState:driverState fromPreviousDriverState:previousState withRide:self.rideDataModel];
    }
    switch (driverState) {
        case InvalidDriverState:
        case OfflineDriverState:
            [FIRAnalytics setUserPropertyString:@"OFFLINE" forName:@"driver_status"];
            
        case AvailableDriverState:
            [FIRAnalytics setUserPropertyString:@"AVAILABLE" forName:@"driver_status"];
            
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
        case AcceptingRequest:
            [FIRAnalytics setUserPropertyString:@"RIDING" forName:@"driver_status"];
    }
    
}

- (void)setRideDataModel:(RARideDataModel *)rideDataModel {
    _rideDataModel = rideDataModel;
    if (self.delegate) {
        [self.delegate driverManagerDidUpdateRide:rideDataModel];
    }
}

- (RARideDataModel *)nextRideDataModel {
    return self.rideDataModel.nextRide;
}

- (void)setNextRide:(RARideDataModel *)nextRide {
    self.rideDataModel.nextRide = nextRide;
    if (self.delegate) {
        [self.delegate driverManagerDidUpdateStackedRide:nextRide];
    }
}

- (void)setRideDataModel:(RARideDataModel *)rideDataModel andDriverState:(DriverState)driverState {
    _rideDataModel = rideDataModel;
    [self setDriverState:driverState];
}

- (void)updateDriverStateFromRide:(RARideDataModel *)rideDataModel {
    _rideDataModel = rideDataModel;
    DriverState driverState = [DriverManager driverStateBasedOnStatus:rideDataModel.status];
    [self setDriverState:driverState];
}

- (void)playSoundForPrevious:(DriverState)previousState toCurrent:(DriverState)currentState {
    switch (previousState) {
        case InvalidDriverState:
        case OfflineDriverState:
            if (currentState == AvailableDriverState) {
                [[SoundManager sharedManager] playSound:SIMToolkitTone4];
            }
            break;
        case AvailableDriverState:
            if (currentState == OfflineDriverState) {
                [[SoundManager sharedManager] playSound:SIMToolkitTone3];
            }
            break;
        case GoingToPickUpDriverState:
            if (currentState == ArrivingToPickUpDriverState) {
                [[SoundManager sharedManager] playSound:AudioTonePathAcknowledge];
            }
            break;
        case ArrivingToPickUpDriverState:
            if (currentState == OnTripDriverState) {
                [[SoundManager sharedManager] playSound:AudioTonePathAcknowledge];
            }
            break;
        case OnTripDriverState:
            if (currentState == AvailableDriverState) {
                [[SoundManager sharedManager] playSound:AudioTonePathAcknowledge];
            }
            break;
        default:
            break;
    }
}

- (void)updateDriverState:(DriverState)driverState {
    if (self.driverState != driverState) {
        [self setDriverState:driverState];
    }
}

+ (void)updateDriverState:(DriverState)driverState {
    [[DriverManager shared] updateDriverState:driverState];
}

- (BOOL)isDriverOnline {
    switch (self.driverState) {
        case InvalidDriverState:
        case OfflineDriverState:
            return NO;
        case AvailableDriverState:
        case ArrivingToPickUpDriverState:
        case GoingToPickUpDriverState:
        case OnTripDriverState:
        case AcceptingRequest:
            return YES;
    }
}

- (BOOL)isDriverOnActiveRide {
    switch (self.driverState) {
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
        case AcceptingRequest:
            return YES;
        case InvalidDriverState:
        case OfflineDriverState:
        case AvailableDriverState:
            return NO;
    }
}

- (void)synchronizeStateSendingLocalCacheIfNeeded:(void (^)(DriverState, RARideDataModel * _Nullable))completion {
    __weak DriverManager *weakSelf = self;
    [[RARideCacheManager sharedManager] flushAllRideCacheWithCompletion:^(BOOL success) {
        [weakSelf synchronizeStateWithCompletion:^(DriverState state, RARideDataModel * _Nullable ride) {
            if (!ride) {
                completion(state, ride);
            } else {
                
                void(^driverStateCacheBlock)(RARideDataModel *) = ^(RARideDataModel *ride) {
                    NSString *rideId = ride.modelID.stringValue;
                    DriverState driverStateCache = [[RARideCacheManager sharedManager] driverStateBasedOnRideCacheWithId:rideId];
                    if (driverStateCache == InvalidDriverState) {
                        driverStateCache = GoingToPickUpDriverState;
                    }
                    [weakSelf setDriverState:driverStateCache];
                    completion(driverStateCache, ride);
                };
                
                NSString *rideId = ride.modelID.stringValue;
                if ([[RARideCacheManager sharedManager] hasCacheForRideWithId:rideId]) {
                    if (ride.nextRide && [[RARideCacheManager sharedManager] hasCompletedInCacheForRideWithId:rideId]) {
                        driverStateCacheBlock(ride.nextRide);
                    } else {
                        driverStateCacheBlock(ride);
                    }
                } else {
                    completion(state, ride);
                }
            }
        }];
    }];
}

/**
 *  @brief the request GET acdr/current
 *  returns 204 if you are offline or marked offline or INACTIVE
 *  returns
 *      STATUS: AVAILABLE if you are online
 *              REQUESTED if you are requested
 *              AWAY if no location updates for n minutes, just set driverState = AvailableDriverState to continue location updates
 *              INACTIVE if AWAY for 30min, currently we receive 204
 *              RIDING when in a ride
 *
 */

- (void)synchronizeStateWithCompletion:(void (^)(DriverState, RARideDataModel * _Nullable))completion {
    __weak DriverManager *weakSelf = self;
    [RAActiveDriversAPI getActiveDriverCurrentWithCompletion:^(RAActiveDriver * _Nullable activeDriver, NSError * _Nullable error) {
        if (error) {
            if (completion) {
                completion(weakSelf.driverState, nil);
            }
        } else {
            //Get Driver Status
            if (activeDriver) {
                BFLog(@"ActiveDriver status : %lu",(unsigned long)activeDriver.status);
                switch (activeDriver.status) {
                    case RAActiveDriverStatusAvailable:
                    case RAActiveDriverStatusRequested:
                    case RAActiveDriverStatusAway:
                        weakSelf.driverState = AvailableDriverState;
                        if (completion) {
                            completion(weakSelf.driverState, nil);
                        }
                        break;
                    case RAActiveDriverStatusInactive:
                        weakSelf.driverState = OfflineDriverState;
                        if (completion) {
                            completion(weakSelf.driverState, nil);
                        }
                        break;
                    case RAActiveDriverStatusRiding: {
                        [weakSelf updateDriverStateFromRide:activeDriver.ride];
                        if (activeDriver.ride == nil) {
                            BFLogErr(@"driver is RIDING without ride");
                            NSString *domain = [NSString stringWithFormat:@"acdr/current unexpected status: RAActiveDriverStatusRiding"];
                            NSError *error = [NSError errorWithDomain:domain code:GETacdrStuck userInfo:nil];
                            [ErrorReporter recordError:error withDomainName:GETacdrStuck];
                        }
                        if (completion) {
                            completion(weakSelf.driverState, activeDriver.ride);
                        }
                    }
                        break;
                }
            } else {
                BFLog(@"ActiveDriver status : NO ACTIVE DRIVER");
                weakSelf.driverState = OfflineDriverState;
                if (completion) {
                    completion(weakSelf.driverState, nil);
                }
            }
        }
    }];
}

#pragma mark - State Execution
- (void)goOfflineWithCompletion:(void (^)(DriverState, NSError * _Nullable))completion {
    switch (self.driverState) {
        case InvalidDriverState:
            [self setDriverState:OfflineDriverState];
            completion(self.driverState, nil);
            break;
            
        case OfflineDriverState:
            completion(self.driverState, nil);
            break;
        
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
            completion(self.driverState, self.cannotLogoutError);
            break;
            
        case AcceptingRequest:
        case AvailableDriverState:
            [RAActiveDriversAPI deleteActiveDriverWithCompletion:^(NSError * _Nullable error) {
                if (error == nil) {
                    [self updateDriverState:OfflineDriverState];
                }
                completion(self.driverState, error);
            }];
            break;
    }
}

- (void)goOnlineWithCompletion:(void (^)(DriverState, NSError * _Nullable))completion {
    __weak __typeof__(self) weakself = self;
    switch (self.driverState) {
        case InvalidDriverState:
        case OfflineDriverState: {
            CLLocation *myLocation = [LocationService sharedService].myLocation;
            RASessionDataModel *currentSession = [RASessionManager shared].currentSession;
            if (!myLocation) {
                if (completion) {
                    completion(self.driverState, self.nilLocationError);
                }
            } else if (!currentSession.driver.active) {
                if (completion) {
                    completion(self.driverState, self.driverInactiveError);
                }
            } else if (!currentSession.driver.user.active) {
                if (completion) {
                    completion(self.driverState, self.driverInactiveError);
                }
            } else {
                CLLocationCoordinate2D coord   = myLocation.coordinate;
                NSString *categories           = [currentSession.userCarTypes componentsJoinedByString:@","];
                NSInteger cityId = [ConfigurationManager shared].global.currentCity.cityID.integerValue;
                [RAActiveDriversAPI postActiveDriverWithLatitude:coord.latitude
                                                       longitude:coord.longitude
                                                          cityId:cityId
                                                   carCategories:categories
                                                      driverType:currentSession.driverTypeFilter
                                                      completion:^(NSError * _Nullable error) {
                                                          if (error == nil) {
                                                              [weakself updateDriverState:AvailableDriverState];
                                                          } else {
                                                              BOOL categoryNeedsToReload = [error.localizedRecoverySuggestion hasPrefix:@"\"Driver not eligible to drive"];
                                                              if (categoryNeedsToReload) {
                                                                  [RASessionManager shared].currentSession.userCarTypes = nil;
                                                                  [[RASessionManager shared] reloadCurrentDriverWithCompletion:nil];
                                                              }
                                                          }
                                                          
                                                          if (completion) {
                                                              completion(weakself.driverState, error);
                                                          }
                                                      }];
            }
        }
            break;
            
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
        case AcceptingRequest:
        case AvailableDriverState:
            if (completion) {
                completion(self.driverState, nil);
            }
            break;
    }
}

- (void)acceptTripFromRideRequestEvent:(id<RARideRequestProtocol>)event withCompletion:(void (^)(NSError * _Nullable))completion {
    RARideDataModel *ride = event.isStackedRide ? event.nextRide : event.ride;
    [RARideAPI acceptRideWithId:ride.modelID andCompletion:^(NSError *error) {
        if (error) {
            completion(error);
        } else {
            //  need to get the latest ride details. Destination could change, status could be cancelled, stacked ride could already be current ride
            [RARideAPI getCurrentRideWithCompletion:^(RARideDataModel *latestRide, NSError *error) {
                if (!error && !latestRide) {
                    [self setRideDataModel:nil   andDriverState:AvailableDriverState];
                    completion(nil);
                    
                    BFLogErr(@"driver is RIDING without ride");
                    NSString *domain = [NSString stringWithFormat:@"rides/current got no ride"];
                    NSError *error = [NSError errorWithDomain:domain code:GETRidesCurrentNoRide userInfo:nil];
                    [ErrorReporter recordError:error withDomainName:GETacdrStuck];
                    return;
                }
                
                [[RARideCacheManager sharedManager] initCacheForRideWithId:ride.modelID.stringValue];
                if (error) {
                    if (event.isStackedRide) {
                        if (self.rideDataModel) {
                            self.rideDataModel.nextRide = ride;
                            [self updateDriverStateFromRide:self.rideDataModel];
                        } else {
                            // in case ride is ended at the same time of accepting stacked ride, stacked ride is now current ride
                            ride.status = @"DRIVER_ASSIGNED";
                            [self updateDriverStateFromRide:ride];
                        }
                    } else {
                        ride.status = @"DRIVER_ASSIGNED";
                        [self updateDriverStateFromRide:ride];
                    }
                } else {
                    [self updateDriverStateFromRide:latestRide];
                }
                completion(nil);
            }];
        }
    }];
}

- (void)reachRiderWithCompletion:(void (^)(void))completion {
    if (self.canReachRider) {
        NSString *rideID = self.rideDataModel.modelID.stringValue;
        [RARideAPI reachedRideWithId:rideID andCompletion:^(NSInteger statusCode, NSError *error) {
            if (error) {
                if (statusCode == 400) {
                    [self synchronizeStateWithCompletion:nil];
                } else {
                    BFLog(@"Cache: Driver arrived to ride with Id : %@ - Handler", rideID);
                    [[RARideCacheManager sharedManager] driverReachedRiderForRideWithId:rideID];
                    self.rideDataModel.status = @"DRIVER_REACHED";
                    self.driverState = ArrivingToPickUpDriverState;
                }
            } else {
                [[RARideCacheManager sharedManager] markRideAsReachedWithId:rideID];
                self.rideDataModel.status = @"DRIVER_REACHED";
                self.driverState = ArrivingToPickUpDriverState;
                BFLog(@"Driver arrived to ride with Id : %@ - Handler", rideID);
            }
            completion();
        }];
    } else {
        completion();
    }
}

- (void)startTripWithCompletion:(void (^)(void))completion {
    if (self.canStartTrip) {
        NSString *rideID = self.rideDataModel.modelID.stringValue;
        
        if ([[RARideCacheManager sharedManager] hasReachedInCacheForRideWithId:rideID]) {
            BFLog(@"Cache: Driver start ride with Id : %@ - Handler", rideID);
            [[RARideCacheManager sharedManager] driverStartedRideWithId:rideID];
            self.rideDataModel.status = @"ACTIVE";
            self.driverState = OnTripDriverState;
            completion();
            return;
        }
        
        [RARideAPI startRideWithId:rideID andCompletion:^(NSInteger statusCode, NSError *error) {
            if (error) {
                if (statusCode == 400) {
                    [self synchronizeStateWithCompletion:nil];
                } else {
                    BFLog(@"Cache: Driver start ride with Id : %@ - Handler", rideID);
                    [[RARideCacheManager sharedManager] driverStartedRideWithId:rideID];
                    self.rideDataModel.status = @"ACTIVE";
                    self.driverState = OnTripDriverState;
                }
            } else {
                [[RARideCacheManager sharedManager] markRideAsStartedWithId:rideID];
                self.rideDataModel.status = @"ACTIVE";
                self.driverState = OnTripDriverState;
                BFLog(@"Driver start ride with Id : %@ - Handler", rideID);
            }
            completion();
        }];
    } else {
        completion();
    }
}

- (void)endTripWithCompletion:(void (^)(RARideDataModel *endedTrip, BOOL isCaching))completion {
    if (self.canEndTrip) {
        CLLocation *location = [LocationService sharedService].myLocation;
        NSString *rideID = self.rideDataModel.modelID.stringValue;
        
        if ([[RARideCacheManager sharedManager] hasStartedInCacheForRideWithId:rideID]) {
            [[RARideCacheManager sharedManager] driverEndRideWithId:rideID atLocation:location.coordinate];
            self.driverState = AvailableDriverState;
            completion(nil, YES);
            return;
        }
        
        [RARideAPI endRideWithId:rideID latitude:location.coordinate.latitude longitude:location.coordinate.longitude andCompletion:^(RARideDataModel *ride, NSError *error) {
            if (error) {
                if (error.code == 400) {
                    [[DriverManager shared] synchronizeStateWithCompletion:nil];
                } else {
                    [[RARideCacheManager sharedManager] driverEndRideWithId:rideID atLocation:location.coordinate];
                    self.driverState = AvailableDriverState;
                }
            } else {
                [[RARideCacheManager sharedManager] markRideAsCompletedWithId:rideID];
            }
            BOOL isCaching = error && error.code != 400;
            completion(ride, isCaching);
        }];
    } else {
        completion(nil, NO);
    }
}

- (void)cancelTripWithCompletion:(void (^)(NSError * _Nullable))completion {
    CFFeedback *feedback = [CFFeedback feedbackForRide:self.rideDataModel.modelID];
    [self cancelTripWithFeedback:feedback andCompletion:completion];
}

- (void)cancelTripWithFeedback:(CFFeedback *)feedback andCompletion:(void (^)(NSError * _Nullable))completion {

    [RARideAPI cancelRide:feedback.rideID withReason:feedback.reasonCode andComment:feedback.comment andCompletion:^(NSError *error) {
        if (error) {
            if (error.code == 400 || error.code == 403) {
                [self synchronizeStateWithCompletion:^(DriverState state, RARideDataModel * _Nullable ride) {
                    completion(error);
                }];
            } else {
                completion(error);
            }
        } else {
            [[RASessionManager shared].currentSession terminateRide:@(feedback.rideID.longLongValue)];
            [self updateDriverState:AvailableDriverState];
            [self synchronizeStateWithCompletion:^(DriverState state, RARideDataModel * _Nullable ride) {
                completion(nil);
            }];
        }
    }];
}
#pragma mark State Validation

- (BOOL)canReachRider {
    switch (self.driverState) {
        case InvalidDriverState:
        case GoingToPickUpDriverState:
            return YES;
            
        case AvailableDriverState:
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
        case AcceptingRequest:
        case OfflineDriverState:
            return NO;
    }
}

- (BOOL)canStartTrip {
    switch (self.driverState) {
        case InvalidDriverState:
        case ArrivingToPickUpDriverState:
            return YES;
            
        case GoingToPickUpDriverState:
        case AvailableDriverState:
        case OnTripDriverState:
        case AcceptingRequest:
        case OfflineDriverState:
            return NO;
    }
}

- (BOOL)canEndTrip {
    switch (self.driverState) {
        case InvalidDriverState:
        case OnTripDriverState:
            return YES;
            
        case GoingToPickUpDriverState:
        case AvailableDriverState:
        case ArrivingToPickUpDriverState:
        case AcceptingRequest:
        case OfflineDriverState:
            return NO;
    }
}
#pragma mark -

#pragma mark - In-app Errors
- (NSError *)cannotLogoutError {
    NSString *message = @"You cannot logout while on active ride.";
    NSDictionary *userInfo = @{NSLocalizedRecoverySuggestionErrorKey : message};
    NSError *error = [NSError errorWithDomain:@"attemptToGoOffline" code:-1 userInfo:userInfo];
    return error;
}

- (NSError *)nilLocationError {
    NSString *message = @"Unable to get your current position. Please, try again later.";
    NSDictionary *userInfo = @{NSLocalizedRecoverySuggestionErrorKey : message};
    return [NSError errorWithDomain:@"attemptToGoOnline" code:-1 userInfo:userInfo];
}

- (NSError *)driverInactiveError {
    NSString *message = @"Sorry, your account has not been activated yet. Please contact our onboarding team at drivers@rideaustin.com.";
    NSDictionary *userInfo = @{NSLocalizedRecoverySuggestionErrorKey : message};
    return [NSError errorWithDomain:@"attemptToGoOnline" code:-1 userInfo:userInfo];
}

- (void)updateCoordinate:(CLLocationCoordinate2D)coordinate course:(double)course speed:(double)speed withCompletion:(void (^)(NSError *error))completion {
    RASessionDataModel *currentSession = [RASessionManager shared].currentSession;
    NSString *userCarTypes = currentSession.userCarTypes.stringArrayToString;
    
    if ([RASessionManager shared].isSignedIn && self.isDriverOnline && userCarTypes) {
        
        UIBackgroundTaskIdentifier identifier = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            DBLog(@"Failed to update");
        }];
        [RAActiveDriversAPI putActiveDriverWithLatitude:coordinate.latitude
                                              longitude:coordinate.longitude
                                                  speed:speed
                                                 course:course
                                          carCategories:userCarTypes
                                             driverType:currentSession.driverTypeFilter
                                             completion:^(id _Nullable activeDriver, NSError * _Nullable error) {
            if (error) {
                BOOL isDriverOffline = error.code == 409; //when marked offline, we need to show that the user is offline
                BOOL isSignedOut     = error.code == 401;
                if (isDriverOffline || isSignedOut) {
                    [self updateDriverState:OfflineDriverState];
                    completion(nil);
                } else {
                    NSString *rideId = self.rideDataModel.modelID.stringValue;
                    [[RARideCacheManager sharedManager] updateDriverLocationForRideWithId:rideId coordinate:coordinate speed:speed heading:course andCourse:course];
                    completion(error);
                }
            } else {
                DBLog(@"Location updated");
                completion(nil);
            }
            [UIApplication.sharedApplication endBackgroundTask:identifier];
        }];
    } else {
        completion(nil);
    }
}
@end
