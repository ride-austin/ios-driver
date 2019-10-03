//
//  JSONHandler.m
//  RideDriver
//
//  Created by Carlos Alcala on 12/1/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "JSONHandler.h"

@implementation JSONHandler

/**
 * Load default config local file based on current target
 * Austin or Houston macros
 */
+(void)getConfigGlobalWithCompletion:(RAConfigGlobalCompletionBlock)handler{
    
    NSString* prefix = nil;
    
    prefix = @"Austin";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@ConfigGlobal", prefix] ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSError *parseError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
    
    if (!parseError) {
        NSError *error;
        ConfigGlobal *config = [MTLJSONAdapter modelOfClass:[ConfigGlobal class]
                                         fromJSONDictionary:json error:&error];
        if (handler) {
            handler(config, nil);
        }
    } else {
        if (handler) {
            handler(nil, parseError);
        }
    }
}


@end
