//
//  DriverManager.h
//  RideDriver
//
//  Created by Carlos Alcala on 9/13/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAEventDataModel.h"
#import "RideDriverEnums.h"
#import "CFFeedback.h"
@class RARideDataModel;

@protocol DriverStateDelegate <NSObject>

- (void)driverManagerDidUpdateDriverState:(DriverState)driverState fromPreviousDriverState:(DriverState)previousDriverState withRide:(RARideDataModel *_Nullable)rideDataModel;
- (void)driverManagerDidUpdateRide:(RARideDataModel *_Nullable)rideDataModel;
- (void)driverManagerDidUpdateStackedRide:(RARideDataModel *_Nullable)nextRide;

@end

@interface DriverManager : NSObject

@property (nonatomic, readonly) DriverState driverState;
/**
 current ride
 */
@property (nonatomic) RARideDataModel * _Nullable rideDataModel;
@property (nonatomic, readonly) RARideDataModel * _Nullable nextRideDataModel;
@property (nonatomic, weak) id <DriverStateDelegate> _Nullable delegate;

+ (DriverManager* _Nonnull)shared;
+ (DriverState)driverStateBasedOnStatus:(NSString *_Nonnull)status;

+ (void)updateDriverState:(DriverState)driverState;
- (void)updateDriverStateFromRide:(RARideDataModel *_Nonnull)rideDataModel;
- (void)setRideDataModel:(RARideDataModel *_Nullable)rideDataModel andDriverState:(DriverState)driverState;
- (void)setNextRide:(RARideDataModel * _Nullable)nextRide;
- (BOOL)isDriverOnline;
- (BOOL)isDriverOnActiveRide;
- (void)synchronizeStateSendingLocalCacheIfNeeded:(void(^_Nullable)(DriverState state, RARideDataModel  * _Nullable ride))completion;
- (void)synchronizeStateWithCompletion:(void(^_Nullable)(DriverState state, RARideDataModel  * _Nullable ride))completion;

#pragma mark - State Execution
- (void)goOfflineWithCompletion:(void(^_Nonnull)(DriverState driverState, NSError * _Nullable error))completion;
- (void)goOnlineWithCompletion:(void(^_Nullable)(DriverState, NSError * _Nullable error))completion;
- (void)acceptTripFromRideRequestEvent:(_Nonnull id<RARideRequestProtocol>)event withCompletion:(void(^_Nonnull)(NSError * _Nullable error))completion;
- (void)reachRiderWithCompletion:(void(^_Nonnull)(void))completion;
- (void)startTripWithCompletion:(void(^_Nonnull)(void))completion;
- (void)endTripWithCompletion:(void(^_Nonnull)(RARideDataModel * _Nullable endedTrip, BOOL isCaching))completion;
- (void)cancelTripWithCompletion:(void(^_Nonnull)(NSError * _Nullable error))completion;
- (void)cancelTripWithFeedback:(CFFeedback *)feedback andCompletion:(void(^_Nonnull)(NSError * _Nullable error))completion;

#pragma mark - Active Driver
- (void)updateCoordinate:(CLLocationCoordinate2D)coordinate course:(double)course speed:(double)speed withCompletion:(void(^_Nonnull)(NSError * _Nullable error))completion;
@end
