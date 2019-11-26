//
//  RAUserAPI.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/3/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseAPI.h"
#import "RAUserDataModel.h"

typedef void(^RAUserAPICompletionBlock)(RAUserDataModel* user, NSError *error);
typedef void (^APICheckResponseBlock)(BOOL failed, NSError* error);

@interface RAUserAPI : RABaseAPI
+ (void) updateUser:(RAUserDataModel*)user withCompletion:(RAUserAPICompletionBlock)completion;
+ (void) checkAvailabilityOfPhone:(NSString*)phoneNumber withCompletion:(APICheckResponseBlock)handler;

@end
