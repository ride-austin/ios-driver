//
//  LIFieldDataModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "LIFieldDataModel.h"

@interface LIFieldDataModel()
@end

@implementation LIFieldDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[self JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
              @"variable"   : @"variable",
              @"fieldTitle" : @"fieldTitle",
              @"fieldType"  : @"fieldType",
              @"fieldPlaceholder" : @"fieldPlaceholder",
              @"isMandatory": @"isMandatory"
            };
}

@end
