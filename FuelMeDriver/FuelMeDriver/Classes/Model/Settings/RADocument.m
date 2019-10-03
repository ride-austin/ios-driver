//
//  RADocument.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/18/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RADocument.h"

@implementation RADocument

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"cityID"         : @"cityId",
              @"documentStatus" : @"documentStatus",
              @"documentType"   : @"documentType",
              @"documentURL"    : @"documentUrl",
              @"documentID"     : @"id",
              @"name"           : @"name",
              @"notes"          : @"notes",
              @"removed"        : @"removed",
              @"validityDate"   : @"validityDate"
            };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return dateFormatter;
}

+ (NSValueTransformer *)documentURLJSONTransformer {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

/**
 *  server returns milliseconds and accepts `yyyy-MM-dd'T'HH:mm:ss`
 */
+ (NSValueTransformer *)validityDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return [self.dateFormatter dateFromString:value];
        } else if ([value isKindOfClass:[NSNumber class]]) {
            return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
        } else {
            return nil;
        }
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:value];
    }];
}

@end
