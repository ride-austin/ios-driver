//
//  QueueZone.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/17/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "QueueZone.h"

@implementation QueueZone

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"areaQueueName" : @"areaQueueName",
              @"lengths" : @"lengths",
              @"iconUrl" : @"iconUrl"
            };
}

- (BOOL)validate:(NSError *__autoreleasing *)error {
    return [super validate:error] && self.areaQueueName != nil;
}

@end
