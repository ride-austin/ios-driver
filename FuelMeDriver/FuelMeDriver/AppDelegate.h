//
//  AppDelegate.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/30/14.
//  Copyright (c) 2014 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)showSplashScreen;

@end
