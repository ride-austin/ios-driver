//
//  ConfigLiveLocation.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "ConfigLiveLocation.h"

@implementation ConfigLiveLocation

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"enabled"  : @"enabled",
              @"requiredAccuracy" : @"requiredAccuracy",
              @"expirationTime" : @"expirationTime"
            };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = false;
        _requiredAccuracy = @(70);
        _expirationTime = @(120);
    }
    return self;
}

@end

@implementation CLLocation (ValidLiveLocation)

- (BOOL)isValidLiveLocationBasedOnConfig:(ConfigLiveLocation *)config {
    return config.enabled && self.horizontalAccuracy <= config.requiredAccuracy.doubleValue;
}

@end
