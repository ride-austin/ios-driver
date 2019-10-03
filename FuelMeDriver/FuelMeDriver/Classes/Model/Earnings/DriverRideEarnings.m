//
//  DriverRideEarnings.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/8/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "DriverRideEarnings.h"

@implementation DriverRideEarnings

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"content" : @"content"
            };
}

+ (NSValueTransformer *)contentJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [MTLJSONAdapter arrayTransformerWithModelClass:RideFareDataModel.class];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSArray *array = [MTLJSONAdapter JSONArrayFromModels:value error:error];
        return array;
    }];
}

@end

@implementation DriverRideEarnings (TestData)

+ (instancetype)earningsWithRides:(NSArray<RideFareDataModel *> *)rideFares {
    return [[self alloc] initWithRides:rideFares];
}

- (instancetype)initWithRides:(NSArray<RideFareDataModel *> *)rideFares {
    if (self = [super init]) {
        _content = rideFares;
    }
    return self;
}

@end
