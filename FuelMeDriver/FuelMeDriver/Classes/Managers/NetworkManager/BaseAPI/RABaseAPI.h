//
//  RABaseAPI.h
//  RideAustin
//
//  Created by Carlos Alcala on 01/24/17.
//  Copyright © 2017 Crossover Markets Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ErrorReporter.h"
#import "NSDictionary+urlEncodedString.h"
#import "NSError+ErrorFactory.h"
#import "RAJSONAdapter.h"
#import "RASessionManager.h"
#import "URLFactory.h"

#import <BugfenderSDK/BugfenderSDK.h>
#import <RestKit/RestKit.h>
#import <SDWebImage/SDWebImagePrefetcher.h>

typedef void (^APIResponseBlock)(id responseObject, NSError* error);
typedef void (^APICheckResponseBlock)(BOOL failed, NSError* error);
typedef void(^APIErrorResponseBlock)(NSError *error);

@interface RABaseAPI : NSObject

@end
