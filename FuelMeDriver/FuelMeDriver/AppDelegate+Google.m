//
//  AppDelegate+Google.m
//  RideDriver
//
//  Created by Roberto Abreu on 14/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate+Google.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppConfig.h"
@import Firebase;
@import FirebaseRemoteConfig;

@implementation AppDelegate (Google)

- (void)setupGoogle {
    [GMSPlacesClient provideAPIKey:[AppConfig googleMapKey]];
    [GMSServices provideAPIKey:[AppConfig googleMapKey]];
    [GMSServices provideAPIOptions:@[@"B3MWHUG2MR0DQW"]];
    [FIRMessaging messaging].delegate = self;
    if (NSProcessInfo.processInfo.environment[@"XCTestConfigurationFilePath"] == nil) {
        [FIRApp configure];
    }
}

#pragma mark - FIRMessagingDelegate

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    DBLog(@"messaging:didReceiveRegistrationToken: %@", fcmToken);
}

- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    
}

@end
