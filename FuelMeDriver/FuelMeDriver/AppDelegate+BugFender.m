//
//  AppDelegate+BugFender.m
//  RideDriver
//
//  Created by Roberto Abreu on 4/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate+BugFender.h"
#import <BugfenderSDK/BugfenderSDK.h>
#import "AppConfig.h"

@implementation AppDelegate (BugFender)

- (void)setupBugFender {
    [Bugfender activateLogger:[AppConfig bugFenderKey]];
    [Bugfender setPrintToConsole:YES];
}

@end
