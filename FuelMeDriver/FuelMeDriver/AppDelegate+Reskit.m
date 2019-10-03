//
//  AppDelegate+Reskit.m
//  RideDriver
//
//  Created by Roberto Abreu on 14/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate+Reskit.h"
#import "RAEnvironmentManager.h"
#import "AppConfig.h"
#import "ConfigurationManager.h"
#import "RASessionManager.h"

static NSString *const kUserAgentHttpHeaderField = @"User-Agent";
static NSString *const kUserPlatformHttpHeaderField = @"User-Platform";
static NSString *const kUserDeviceHttpHeaderField = @"User-Device";
static NSString *const kUserDeviceIDHttpHeaderField = @"User-Device-Id";
static NSString *const kUserDeviceOtherHttpHeaderField = @"User-Device-Other";

@implementation AppDelegate (RestKit)

+ (RKObjectManager *)objectManager {
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[RAEnvironmentManager sharedManager].serverUrl]];
    [AppDelegate setupHeadersForObjectManager:objectManager];
    return objectManager;
}

- (void)setUpRestKit {
    RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
    [AFRKNetworkActivityIndicatorManager sharedManager].enabled = YES;
    RKObjectManager *objectManager = [AppDelegate objectManager];
    [RKObjectManager setSharedManager:objectManager];
}

+ (void)setupHeadersForObjectManager:(RKObjectManager *)objectManager {
    [objectManager.HTTPClient setDefaultHeader:@"Accept" value:@"application/json, image/png, */*"];
    [objectManager.HTTPClient setDefaultHeader:@"Content-type" value:@"application/json"];
#if RELEASEENTERPRISE || QA
    NSString *userAgent = [NSString stringWithFormat:@"%@Driver_iOS_%@", [[ConfigurationManager localAppName] stringByReplacingOccurrencesOfString:@" " withString:@""],[RAEnvironmentManager sharedManager].version];
#else
    NSString *userAgent = [NSString stringWithFormat:@"%@Driver_iOSAppStore_%@", [[ConfigurationManager localAppName] stringByReplacingOccurrencesOfString:@" " withString:@""],[RAEnvironmentManager sharedManager].version];
#endif
    
    [objectManager.HTTPClient setDefaultHeader:kUserAgentHttpHeaderField value:userAgent];
    [objectManager.HTTPClient setDefaultHeader:@"Accept-Version" value:@"1.0.0"];
    
    NSString *token = [RASessionManager shared].currentSession.authToken;
    if (token) {
        [objectManager.HTTPClient setDefaultHeader:@"X-Auth-Token" value:token];
    }
    [objectManager.HTTPClient setDefaultHeader:@"X-Api-Key" value:[AppConfig apiKey]];
    objectManager.requestSerializationMIMEType=RKMIMETypeJSON;
    
    //UDID headers
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSString *userPlatform = [[currentDevice systemName] stringByAppendingFormat:@" %@",[currentDevice systemVersion]];
    NSString *userModel = [currentDevice modelType] ? [currentDevice modelType] : [currentDevice model];
    NSString *userUUID = [currentDevice uniqueDeviceIdentifier];
    NSString *userDeviceName = [currentDevice name];
    
    [objectManager.HTTPClient setDefaultHeader:kUserPlatformHttpHeaderField value:userPlatform];
    [objectManager.HTTPClient setDefaultHeader:kUserDeviceHttpHeaderField value:userModel];
    [objectManager.HTTPClient setDefaultHeader:kUserDeviceIDHttpHeaderField value:userUUID];
    [objectManager.HTTPClient setDefaultHeader:kUserDeviceOtherHttpHeaderField value:userDeviceName];
}

@end
