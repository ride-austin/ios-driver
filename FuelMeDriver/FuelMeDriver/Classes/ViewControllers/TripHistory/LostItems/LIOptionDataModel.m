//
//  LIOptionDataModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "LIOptionDataModel.h"

@implementation LIOptionDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[self JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
              @"actionTitle": @"actionTitle",
              @"actionType" : @"actionType",
              @"body"       : @"body",
              @"fields"     : @"supportFields",
              @"headerText" : @"headerText",
              @"title"      : @"title"
            };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)fieldsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:LIFieldDataModel.class];
}

@end
