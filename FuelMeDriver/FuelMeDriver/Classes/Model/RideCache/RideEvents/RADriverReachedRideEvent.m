//
//  RADriverReachedRideEvent.m
//  RideDriver
//
//  Created by Marcos Alba on 4/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RADriverReachedRideEvent.h"

@implementation RADriverReachedRideEvent

@end

#pragma mark - RideEvent Protocol

@implementation RADriverReachedRideEvent (EventProtocol)

+ (NSString *)eventType {
    return @"DRIVER_REACHED";
}

@end
