//
//  RAActiveDriversCar.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAActiveDriversCar.h"

@implementation RAActiveDriversCarDriver

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"user":@"user"
             };
}

+ (NSValueTransformer *)userJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RABaseDataModel.class];
}

@end

@implementation RAActiveDriversCar
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"course"      : @"course",
             @"driver"      : @"driver",
             @"latitude"    : @"latitude",
             @"longitude"   : @"longitude"
             };
}

+ (NSValueTransformer *)driverJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RAActiveDriversCarDriver.class];
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}
@end
