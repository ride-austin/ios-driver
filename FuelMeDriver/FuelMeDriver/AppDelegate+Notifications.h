//
//  AppDelegate+Notifications.h
//  RideDriver
//
//  Created by Robert on 14/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate (Notifications) <UNUserNotificationCenterDelegate>

- (void)setupNotifications;

@end
