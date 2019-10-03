//
//  ConfigRideCancellation.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/26/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigRideCancellation.h"

@implementation ConfigRideCancellation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"isEnabled" : @"enabled"
            };
}

@end
