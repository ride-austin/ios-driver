//
//  AppDelegate+Notifications.m
//  RideDriver
//
//  Created by Robert on 14/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate+Notifications.h"
#import "RideDriverConstants.h"
#import "PopupManagerDefines.h"
#import "AppDelegate+Extensions.h"
#import "UIDevice+Unique.h"
#import "NSString+DeviceToken.h"
#import "UIMutableUserNotificationAction+Initializer.h"
#import "ConfigurationManager.h"

#import "NetworkManager.h"
#import "PersistenceManager.h"
#import "LocationViewController.h"
#import "RASessionManager.h"
#import "AutoAvailabilityManager.h"
#import "RAAlertManager+Extension.h"

@implementation AppDelegate (Notifications)

#pragma mark - Setup notifications and categories

- (void)setupNotifications {
    UIApplication *application = [UIApplication sharedApplication];
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) ) {
        // Register for Notifications, if running <= iOS 9
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            [self setupCategories];
        }
    } else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if(!error) {
                                      
                                  } else {
                                      DBLog( @"setupNotifications ERROR: %@", error);
                                  }
                              }];
        [self setupCategories];
    }
    [application registerForRemoteNotifications];
}

- (void) setupCategories {
    
    if(SYSTEM_VERSION_LESS_THAN( @"10.0" )) {
        //<iOS9]
        //Category LocalNotification NearDestination
        UIMutableUserNotificationAction *actionNearDestinationYes = [UIMutableUserNotificationAction actionWithIdentifier:kLocalNotificationNearDestinationYES title:@"Yes" activationMode:UIUserNotificationActivationModeForeground destructive:YES authenticationRequired:YES];
        
        UIMutableUserNotificationAction *actionNearDestinationNo = [UIMutableUserNotificationAction actionWithIdentifier:kLocalNotificationNearDestinationNO title:@"No" activationMode:UIUserNotificationActivationModeBackground destructive:NO authenticationRequired:NO];
        
        UIMutableUserNotificationCategory *categoryNearDestination = [UIMutableUserNotificationCategory new];
        categoryNearDestination.identifier = kLocalNotificationNearDestinationID;
        [categoryNearDestination setActions:@[actionNearDestinationYes, actionNearDestinationNo] forContext:UIUserNotificationActionContextDefault];
        
        //Category LocalNotification ForgetToStarTRide
        UIMutableUserNotificationAction *actionForgetToStartRideYes = [UIMutableUserNotificationAction actionWithIdentifier:kLocalNotificationAwayFromPickupSTART title:@"Start" activationMode:UIUserNotificationActivationModeBackground destructive:YES authenticationRequired:YES];
        
        UIMutableUserNotificationAction *actionForgetToStartRideNo = [UIMutableUserNotificationAction actionWithIdentifier:kLocalNotificationAwayFromPickupNOTYET title:@"Not yet" activationMode:UIUserNotificationActivationModeBackground destructive:NO authenticationRequired:NO];
        
        UIMutableUserNotificationCategory *categoryForgetToStartRide = [UIMutableUserNotificationCategory new];
        categoryForgetToStartRide.identifier = kLocalNotificationAwayFromPickupID;
        [categoryForgetToStartRide setActions:@[actionForgetToStartRideYes, actionForgetToStartRideNo] forContext:UIUserNotificationActionContextDefault];
        
        //Category Availability Notification
        UIMutableUserNotificationAction *actionGoOnline = [UIMutableUserNotificationAction actionWithIdentifier:kLocalNotificationAvailabilityGoOnline  title:@"Go Online" activationMode:UIUserNotificationActivationModeForeground destructive:NO authenticationRequired:NO];
        
        UIMutableUserNotificationAction *actionGoOffline = [UIMutableUserNotificationAction actionWithIdentifier:kLocalNotificationAvailabilityGoOffline title:@"Go Offline" activationMode:UIUserNotificationActivationModeBackground destructive:YES authenticationRequired:NO];
        
        UIMutableUserNotificationCategory *categoryAvailability = [UIMutableUserNotificationCategory new];
        categoryAvailability.identifier = kLocalNotificationAvailabilityId;
        [categoryAvailability setActions:@[actionGoOnline, actionGoOffline] forContext:UIUserNotificationActionContextDefault];
        
        UIMutableUserNotificationCategory *categoryOffline = [UIMutableUserNotificationCategory new];
        categoryOffline.identifier = kLocalNotificationOfflineId;
        [categoryOffline setActions:@[actionGoOnline] forContext:UIUserNotificationActionContextDefault];
        
        //Register categories
        NSSet *categories = [NSSet setWithObjects:categoryNearDestination, categoryForgetToStartRide, categoryAvailability, categoryOffline, nil];
        UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
    } else {
        //iOS10+
        //Category LocalNotification NearDestination
        UNNotificationAction *actionNearDestinationYes = [UNNotificationAction actionWithIdentifier:kLocalNotificationNearDestinationYES title:@"Yes" options:UNNotificationActionOptionForeground];
        
        UNNotificationAction *actionNearDestinationNo = [UNNotificationAction actionWithIdentifier:kLocalNotificationNearDestinationNO title:@"No" options:UNNotificationActionOptionDestructive];
        
        UNNotificationCategory* categoryNearDestination = [UNNotificationCategory categoryWithIdentifier:kLocalNotificationNearDestinationID actions:@[actionNearDestinationYes, actionNearDestinationNo] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        
        //Category LocalNotification ForgetToStartRide
        UNNotificationAction *actionForgetToStartRideYes = [UNNotificationAction actionWithIdentifier:kLocalNotificationAwayFromPickupSTART title:@"Start" options:UNNotificationActionOptionForeground];
        
        UNNotificationAction *actionForgetToStartRideNo = [UNNotificationAction actionWithIdentifier:kLocalNotificationAwayFromPickupNOTYET title:@"Not yet" options:UNNotificationActionOptionDestructive];
        
        UNNotificationCategory *categoryForgetToStartRide = [UNNotificationCategory categoryWithIdentifier:kLocalNotificationAwayFromPickupID actions:@[actionForgetToStartRideYes, actionForgetToStartRideNo] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        
        //Category Availability Notification
        UNNotificationAction *actionGoOnline = [UNNotificationAction actionWithIdentifier:kLocalNotificationAvailabilityGoOnline title:@"Go Online" options:UNNotificationActionOptionForeground];
        
        UNNotificationAction *actionGoOffline = [UNNotificationAction actionWithIdentifier:kLocalNotificationAvailabilityGoOffline title:@"Go Offline" options:UNNotificationActionOptionDestructive];
        
        UNNotificationCategory *categoryAvailability = [UNNotificationCategory categoryWithIdentifier:kLocalNotificationAvailabilityId actions:@[actionGoOnline, actionGoOffline] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        
        UNNotificationCategory *categoryOffline = [UNNotificationCategory categoryWithIdentifier:kLocalNotificationOfflineId actions:@[actionGoOnline] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        
        //Set Categories
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithArray:@[categoryNearDestination, categoryForgetToStartRide, categoryAvailability, categoryOffline]]];
    }
    
}

#pragma mark - Setup remote notifications

- (void)registerToken:(NSString*)deviceToken {
    if ([RASessionManager shared].isSignedIn) {
        BOOL tokenHasChanged = deviceToken && [deviceToken isEqualToString:[PersistenceManager cachedDeviceToken]] == NO;
        if (tokenHasChanged) {
            [NetworkManager registerDeviceToken:deviceToken
                                    andDeviceID:[UIDevice currentDevice].uniqueDeviceIdentifier];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
#warning should we always removed the cached value?
    [PersistenceManager removeCachedDeviceToken];
    [self registerToken:[NSString convertDeviceTokenToString:deviceToken]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *message = [NSString stringWithFormat:@"We are unable to register your device for push notifications! Please check your notification settings for %@.", [ConfigurationManager localAppName]];
    [RAAlertManager showAlertWithTitle:@"SORRY" message:message options:[RAAlertOption optionWithState:StateActive]];
#endif

    DBLog(@"didFailToRegisterForRemoteNotificationsWithError : %@", error);
}

#pragma mark - UNNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    [self handleNotificationWithActionIdentifier:response.actionIdentifier];
    completionHandler();
}

#pragma mark - Appliacation notification delegate support <iOS10

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        NSString *alertTitle = [ConfigurationManager appName];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
            alertTitle = notification.alertTitle ?: [ConfigurationManager appName];
        }
        
        NSString *actionTitle = notification.alertAction ?: @"Dismiss";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *userInfo = notification.userInfo;
            NSString *notificationName = userInfo[@"notificationName"];
            if ([kAcceptRideRequestNotification isEqualToString:notificationName]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kAcceptRideRequestNotification object:nil userInfo:notification.userInfo];
            }
        }];
        
        [alertController addAction:dismiss];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)(void))completionHandler {
    [self handleNotificationWithActionIdentifier:identifier];
    completionHandler();
}

#pragma mark - Handle Action

- (void)handleNotificationWithActionIdentifier:(NSString*)action {
    if (self.locationViewController) {
        if ([action isEqualToString:kLocalNotificationNearDestinationYES]) {
            [self.locationViewController didEndTripFromLocalNotification];
        } else if ([action isEqualToString:kLocalNotificationAwayFromPickupSTART]) {
            [self.locationViewController didStartTripFromAlerts];
        } else if ([action isEqualToString:kLocalNotificationAwayFromPickupNOTYET]){
            [self.locationViewController checkIfDriverHasStartedTripWithoutSlidingButton];
        } else if ([action isEqualToString:kLocalNotificationAvailabilityGoOnline]) {
            [[AutoAvailabilityManager sharedManager] stopMonitoringAvailability];
            [[DriverManager  shared] goOnlineWithCompletion:^(DriverState driverState, NSError *error) {
                if (error) {
                    [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
                }
            }];
        } else if ([action isEqualToString:kLocalNotificationAvailabilityGoOffline]) {
            [[AutoAvailabilityManager sharedManager] stopMonitoringAvailability];
            [[AutoAvailabilityManager sharedManager] goOfflineWithHandler];
        }
    }
}

@end
