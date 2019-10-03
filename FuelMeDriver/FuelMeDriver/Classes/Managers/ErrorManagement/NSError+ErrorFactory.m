//
//  NSError+ErrorFactory.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "NSError+ErrorFactory.h"
#import "RAEnvironmentManager.h"
#import "RASessionManager.h"
#import "RideUser.h"

@implementation NSError (ErrorFactory)

- (NSError *)filteredErrorAtReponse:(NSHTTPURLResponse *)response {
    NSMutableDictionary *userInfo = self.userInfo ? [NSMutableDictionary dictionaryWithDictionary:self.userInfo] : [NSMutableDictionary dictionary];
    
    NSString* recoveryOptions = userInfo[NSLocalizedRecoverySuggestionErrorKey];
    if ([recoveryOptions.lowercaseString hasPrefix:@"<html"] ||
        [recoveryOptions.lowercaseString hasSuffix:@"</html>"]) {
        recoveryOptions = nil;
    }
    
    switch (self.code) {
        case NSURLErrorTimedOut:
        case NSURLErrorNotConnectedToInternet:
            return [NSError errorWithDomain:self.domain code:self.code userInfo:userInfo];
        default:
            [[RASessionManager shared] handle401Response:response];
            return [self errorWithStatusCode:response.statusCode];
    }
}

- (NSError *)errorWithStatusCode:(NSInteger)statusCode {
    NSMutableDictionary *userInfo = self.userInfo ? [NSMutableDictionary dictionaryWithDictionary:self.userInfo] : [NSMutableDictionary dictionary];
    
    NSString* recoveryOptions = userInfo[NSLocalizedRecoverySuggestionErrorKey];
    if ([recoveryOptions.lowercaseString hasPrefix:@"<html"] ||
        [recoveryOptions.lowercaseString hasSuffix:@"</html>"]) {
        recoveryOptions = nil;
    }
    NSString *version = [NSString stringWithFormat:@" (%@)", [RAEnvironmentManager sharedManager].version];
    
    NSMutableString *displayMessage = [NSMutableString new];
    [displayMessage appendString:[self messageBasedOnStatusCode:statusCode andRecoveryOptions:recoveryOptions]];
    [displayMessage appendString:version];
    userInfo[NSLocalizedRecoverySuggestionErrorKey] = displayMessage;
    return [NSError errorWithDomain:self.domain code:statusCode userInfo:userInfo];
}

- (NSString *)messageBasedOnStatusCode:(NSInteger)statusCode
                    andRecoveryOptions:(NSString *)recoveryOptions {
    if (recoveryOptions) {
        return recoveryOptions;
    } else {
        switch (statusCode) {
            case 0:     return self.localizedDescription;
            case 400:   return @"There was an issue with your request. Please contact support.";
            case 401:   return @"You are not authorized.";
            case 403:   return @"You are not allowed to view this resource.";
            case 404:   return @"Resource does not exist.";
            case 409:   return @"Resource already exists";
            case 500:   //fallthrough
            default:
                return [NSString stringWithFormat:@"We are currently experiencing technical issues! (Code:%li)", (long)statusCode];
        }
    
    }
}

@end
