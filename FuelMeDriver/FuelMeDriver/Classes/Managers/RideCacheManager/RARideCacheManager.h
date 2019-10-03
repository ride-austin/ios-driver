//
//  RARideCacheManager.h
//  RideDriver
//
//  Created by Kitos on 6/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RARideCacheManagerDelegate.h"
#import "RARideEvents.h"
#import "RideDriverEnums.h"

@interface RARideCacheManager : NSObject

@property (nonatomic, weak) id<RARideCacheManagerDelegate> delegate;
@property (nonatomic, readonly, getter=hasCacheToFlush) BOOL cacheToFlush;

+ (RARideCacheManager*)sharedManager;

#pragma mark - Cache Events
- (void)initCacheForRideWithId:(NSString *)rideId;
- (void)endCacheForRideWithId:(NSString *)rideId;
- (void)driverReachedRiderForRideWithId:(NSString *)rideId;
- (void)driverStartedRideWithId:(NSString *)rideId;
- (void)updateDriverLocationForRideWithId:(NSString *)rideId coordinate:(CLLocationCoordinate2D)coordinate speed:(CLLocationSpeed)speed heading:(CLLocationDirection)heading andCourse:(CLLocationDirection)course;
- (void)driverEndRideWithId:(NSString *)rideId atLocation:(CLLocationCoordinate2D)coordinate;

#pragma mark - Cache Events Helper
- (void)markRideAsReachedWithId:(NSString *)rideId;
- (void)markRideAsStartedWithId:(NSString *)rideId;
- (void)markRideAsCompletedWithId:(NSString *)rideId;
- (BOOL)hasReachedInCacheForRideWithId:(NSString *)rideId;
- (BOOL)hasStartedInCacheForRideWithId:(NSString *)rideId;
- (BOOL)hasCompletedInCacheForRideWithId:(NSString *)rideId;
- (BOOL)hasCacheForRideWithId:(NSString *)rideId;
- (DriverState)driverStateBasedOnRideCacheWithId:(NSString *)rideId;

#pragma mark - Flush Events
- (void)flushAllRideCacheWithCompletion:(void(^)(BOOL success))completion;

@end

@interface RARideCacheManager (Testing)

- (void)removeCache;

@end
