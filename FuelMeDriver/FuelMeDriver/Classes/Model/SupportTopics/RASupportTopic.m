//
//  RASupportTopic.m
//  RideDriver
//
//  Created by Robert on 10/3/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RASupportTopic.h"

@implementation RASupportTopic

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[self JSONKeyPaths]];
}

+ (NSDictionary*)JSONKeyPaths {
    return @{ @"topicDescription" : @"description",
              @"hasChildren"      : @"hasChildren",
              @"hasForms"         : @"hasForms"
            };
}

@end
