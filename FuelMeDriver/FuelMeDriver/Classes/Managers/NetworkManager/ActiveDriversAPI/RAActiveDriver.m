//
//  RAActiveDriver.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAActiveDriver.h"

@implementation RAActiveDriver

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"modelID" : @"id",
             @"status" : @"status",
             @"ride"   : @"ride",
             @"driver" : @"driver",
             @"selectedCar" : @"selectedCar",
             @"onlineCarCategories" : @"carCategories"
             };
}

+ (NSValueTransformer *)statusJSONTransformer {
    NSDictionary *states =
    @{
      @"INACTIVE"  : @(RAActiveDriverStatusInactive),
      @"AVAILABLE" : @(RAActiveDriverStatusAvailable),
      @"RIDING"    : @(RAActiveDriverStatusRiding),
      @"REQUESTED" : @(RAActiveDriverStatusRequested),
      @"AWAY"      : @(RAActiveDriverStatusAway)
      };
    return [MTLValueTransformer mtl_valueMappingTransformerWithDictionary:states defaultValue:@(RAActiveDriverStatusInactive) reverseDefaultValue:nil];
}

+ (NSValueTransformer *)rideJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RARideDataModel.class];
}

+ (NSValueTransformer *)driverJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RADriverDataModel.class];
}

+ (NSValueTransformer *)selectedCarJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Car.class];
}

@end
