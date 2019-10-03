//
//  RAJSONAdapter.h
//  Ride
//
//  Created by Roberto Abreu on 6/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAJSONAdapter : NSObject
/**
 @param isNullable will Assert if the response is not expected to be nil
 */
+ (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)json isNullable:(BOOL)isNullable;
/**
 @param isNullable will Assert if the response is not expected to be nil
 */
+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)json isNullable:(BOOL)isNullable;

@end
