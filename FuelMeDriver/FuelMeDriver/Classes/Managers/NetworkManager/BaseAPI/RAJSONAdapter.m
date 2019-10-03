//
//  RAJSONAdapter.m
//  Ride
//
//  Created by Roberto Abreu on 6/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAJSONAdapter.h"

#import <Mantle/Mantle.h>

@implementation RAJSONAdapter

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)JSONDictionary {
    return [self modelOfClass:modelClass
           fromJSONDictionary:JSONDictionary
                   isNullable:NO];
}

+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray {
    return [self modelsOfClass:modelClass
                 fromJSONArray:JSONArray
                    isNullable:NO];

}

+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)json isNullable:(BOOL)isNullable {
    if (json == nil && isNullable) {
        return nil;
    } else {
        NSError *error;
        id response = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:json error:&error];
#ifdef QA
        NSAssert(!error, @"Error while mapping %@ error: %@", NSStringFromClass(modelClass), error);
#endif
        return response;
    }
}
+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)json isNullable:(BOOL)isNullable {
    if (json == nil && isNullable) {
        return nil;
    } else {
        NSError *error;
        id response = [MTLJSONAdapter modelsOfClass:modelClass fromJSONArray:json error:&error];
#ifdef QA
        NSAssert(!error, @"Error while mapping %@ error: %@", NSStringFromClass(modelClass), error);
#endif
        return response;
    }
}
@end
