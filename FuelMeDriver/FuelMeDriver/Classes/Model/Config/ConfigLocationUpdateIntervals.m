//
//  ConfigLocationUpdateIntervals.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/28/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ConfigLocationUpdateIntervals.h"

@implementation ConfigLocationUpdateIntervals

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"movementSpeed"       : @"movementSpeed",
             @"whenOnTrip"          : @"whenOnTrip",
             @"whenOnlineAndMoving" : @"whenOnlineAndMoving",
             @"whenOnlineAndNotMoving" : @"whenOnlineAndNotMoving"
             };
}

- (instancetype)init {
    if (self = [super init]) {
        _movementSpeed  = @(2);
        _whenOnTrip     = @(2);
        _whenOnlineAndMoving    = @(7);
        _whenOnlineAndNotMoving = @(12);
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    if (self = [super initWithDictionary:dictionaryValue error:error]) {
        if (!_movementSpeed ||
           ![_movementSpeed isKindOfClass:[NSNumber class]]) {
             _movementSpeed = @(2);
        }
        if (!_whenOnTrip ||
           ![_whenOnTrip isKindOfClass:[NSNumber class]]) {
             _whenOnTrip = @(2);
        }
        if (!_whenOnlineAndMoving ||
           ![_whenOnlineAndMoving isKindOfClass:[NSNumber class]]) {
             _whenOnlineAndMoving = @(7);
        }
        if (!_whenOnlineAndNotMoving ||
           ![_whenOnlineAndNotMoving isKindOfClass:[NSNumber class]]) {
             _whenOnlineAndNotMoving = @(12);
        }
    }
    return self;
}

@end
