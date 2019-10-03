//
//  RARideStartedRideEvent.m
//  RideDriver
//
//  Created by Marcos Alba on 4/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARideStartedRideEvent.h"

@implementation RARideStartedRideEvent

@end

#pragma mark - RideEvent Protocol

@implementation RARideStartedRideEvent (EventProtocol)

+ (NSString *)eventType {
    return @"START_RIDE";
}

@end
