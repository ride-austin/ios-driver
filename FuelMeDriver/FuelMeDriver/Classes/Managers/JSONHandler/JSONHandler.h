//
//  JSONHandler.h
//  RideDriver
//
//  Created by Carlos Alcala on 12/1/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigGlobal.h"

@interface JSONHandler : NSObject

typedef void(^RAConfigGlobalCompletionBlock)(ConfigGlobal* config, NSError* error);

+(void)getConfigGlobalWithCompletion:(RAConfigGlobalCompletionBlock)handler;

@end
