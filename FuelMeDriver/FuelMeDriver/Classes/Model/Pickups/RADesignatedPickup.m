//
//  RADesignatedPickup.m
//  Ride
//
//  Created by Roberto Abreu on 9/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RADesignatedPickup.h"

@implementation RADesignatedPickup

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"name" : @"name",
              @"driverCoord" : @"driverCoord"
            };
}

+ (NSValueTransformer *)driverCoordJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RACoordinate class]];
}

@end
