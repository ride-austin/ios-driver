//
//  ConfigRideAcceptance.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/28/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ConfigRideAcceptance.h"

@implementation ConfigRideAcceptance

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"acceptancePeriod" : @"acceptancePeriod",
              @"allowancePeriod"  : @"allowancePeriod"
            };
}

- (instancetype)init {
    if (self = [super init]) {
        _acceptancePeriod = @(10);
        _allowancePeriod = @(5);
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    if (self = [super initWithDictionary:dictionaryValue error:error]) {
        if (!_acceptancePeriod ||
           ![_acceptancePeriod isKindOfClass:[NSNumber class]]) {
             _acceptancePeriod = @(10);
        }
        if (!_allowancePeriod ||
            ![_allowancePeriod isKindOfClass:[NSNumber class]]) {
            _allowancePeriod = @(5);
        }
    }
    return self;
}

@end
