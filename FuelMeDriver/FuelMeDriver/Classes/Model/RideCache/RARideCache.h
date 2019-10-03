//
//  RARideCache.h
//  RideDriver
//
//  Created by Kitos on 6/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RARideEvent.h"
#import "RideDriverEnums.h"

@interface RARideCache : NSObject

@property (nonatomic, readonly) NSString *rideID;
@property (nonatomic, readonly) NSDictionary <NSString*, RARideEvent*> *events;
@property (nonatomic, readonly) BOOL hasData;
@property (nonatomic, getter=wasReachedPickup) BOOL reachedPickup;
@property (nonatomic, getter=wasTripStarted) BOOL tripStarted;
@property (nonatomic, getter=wasCompleted) BOOL completed;
@property (nonatomic, readonly) NSDictionary *jsonObject;

+ (RARideCache*)rideCacheForRideID:(NSString*)rideID;
- (instancetype)initWithRideID:(NSString*)rideID;
- (void)addRideEvent:(RARideEvent*)rideEvent;
- (void)cleanCache;
- (DriverState)driverState;

@end
