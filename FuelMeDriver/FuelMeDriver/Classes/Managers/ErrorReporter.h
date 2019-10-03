//
//  ErrorReporter.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/6/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ERDomains.h"

@interface ErrorReporter : NSObject
/**
 *  @brief will report error with domainName = erDomainName and send object "response" to crashlytics
 *  use this when you are expecting a specific response but got something else
 *  @return generic error
 */
+(NSError *)recordErrorDomainName:(ERDomain)erDomainName withInvalidResponse:(id)response;
/**
 *  @brief will report error with domainName = erDomainName
 *  @return generic error
 */
+(NSError *)recordErrorDomainName:(ERDomain)erDomainName withUserInfo:(NSDictionary *)userInfo;
/**
 *  @brief will report error with domainName = customDomainName
 */
+(void)recordError:(NSError *)error withDomainName:(ERDomain)erDomainName andCustomName:(NSString *)customDomainName;
/**
 *  @brief will report error with domainName = ERDomain
 */
+(void)recordError:(NSError *)error withDomainName:(ERDomain)erDomainName;

/**
 *  @brief will report connectivity error
 */
+ (BOOL)reportConnectivityError:(NSError*)error;
@end
