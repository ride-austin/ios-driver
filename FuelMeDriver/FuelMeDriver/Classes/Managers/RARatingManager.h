//
//  RARatingManager.h
//  RideDriver
//
//  Created by Roberto Abreu on 11/8/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RARideDataModel.h"
#import "RideRate.h"

@interface RARatingManager : NSObject

+ (void)addRideRatedToCache:(RideRate *)rideRate;
+ (void)sendRideRatedCacheToServer;

@end
