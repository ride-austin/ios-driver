//
//  ConfigDriverActions.m
//  RideDriver
//
//  Created by Abdul Rehman on 03/10/2018.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

#import "ConfigDriverActions.h"

@implementation ConfigDriverActions


+ (NSDictionary *)JSONKeyPathsByPropertyKey { 
    return @{
             @"autoArriveDistanceToPickup"          : @"autoArriveDistanceToPickup",
             @"autoEndDistanceToDestination"        : @"autoEndDistanceToDestination",
             @"allowArriveDistanceToPickup"         : @"allowArriveDistanceToPickup",
             @"remindToArriveDistanceFromPickup"    : @"remindToArriveDistanceFromPickup"
             };
}

@end
