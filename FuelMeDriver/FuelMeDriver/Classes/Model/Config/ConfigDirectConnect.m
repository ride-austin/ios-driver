//
//  ConfigDirectConnect.m
//  RideDriver
//
//  Created by Roberto Abreu on 11/13/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ConfigDirectConnect.h"

@implementation ConfigDirectConnect

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"isEnabled" : @"enabled",
              @"title" : @"title",
              @"directConnectDescription" : @"description",
              @"requiresChauffeur" : @"requiresChauffeur"
            };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    if (self = [super initWithDictionary:dictionaryValue error:error]) {
        _isEnabled = YES;
        _title = _title ?: @"Direct Connect";
        _directConnectDescription = _directConnectDescription ?: @"To connect with a Rider directly, please have the rider to input this Driver ID:";
    }
    return self;
}

@end


