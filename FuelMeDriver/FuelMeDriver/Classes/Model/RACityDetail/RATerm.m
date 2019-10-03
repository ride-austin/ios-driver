//
//  RATerm.m
//  RideDriver
//
//  Created by Roberto Abreu on 5/25/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RATerm.h"

@implementation RATerm

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"modelID" : @"currentTermsId",
              @"url"     : @"currentTermsUrl",
              @"version" : @"currentTermsVersion",
              @"publication" : @"currentTermsPublicationDate"
            };
}

+ (NSValueTransformer*)urlJSONTransformer {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer*)publicationJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        double timestamp = value.doubleValue / 1000;
        return [NSDate dateWithTimeIntervalSince1970:timestamp];
    }];
}

@end
