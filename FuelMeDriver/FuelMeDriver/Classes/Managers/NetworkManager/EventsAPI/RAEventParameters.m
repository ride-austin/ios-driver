//
//  RAEventParameters.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/18/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAEventParameters.h"

@implementation RAEventParameters

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *JSONKeyPaths =
    @{
      @"handshakeExpiration" : @"handshakeExpiration",
      @"acceptanceExpiration" : @"acceptanceExpiration",
      @"acknowledgeExpiration" : @"acknowledgeExpiration",
      @"latitude":@"lat",
      @"longitude":@"lng",
      @"timestamp":@"timeRecorded",
      @"source" : @"source",
      @"message" : @"message",
      @"disabled" : @"disabled",
      @"areaQueueName" : @"areaQueueName",
      @"rideId" : @"rideId",
      @"surgeAreas" : @"surgeAreas"
      };
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:JSONKeyPaths];
}

+ (NSValueTransformer *)timestampJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return [NSDate dateWithTimeIntervalSince1970:value.doubleValue/1000];
        } else {
            return nil;
        }
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSDate class]]) {
            return  @(value.timeIntervalSince1970 * 1000);
        } else {
            return nil;
        }
    }];
}

+ (NSValueTransformer *)surgeAreasJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:SurgeArea.class];
}
@end

@implementation RAEventParameters (EventStubGenerator)
+(instancetype)parametersFromJSON:(NSDictionary *)json {
    NSError *error;
    RAEventParameters *parameters = [MTLJSONAdapter modelOfClass:[RAEventParameters class] fromJSONDictionary:json error:&error];
    NSAssert(error == nil, @"RAEventParameters mapping error: %@", error);
    return parameters;
}
@end
