//
//  AppDelegate.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/30/14.
//  Copyright (c) 2014 FuelMe LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationService.h"
#import "RideDriverConstants.h"
#import "PopupManagerDefines.h"
#import "ConfigurationManager.h"
#import "AppDelegate+Google.h"
#import "AppDelegate+Reskit.h"
#import "AppDelegate+Appearance.h"
#import "AppDelegate+LoadData.h"
#import "AppDelegate+Extensions.h"
#import "AppDelegate+NetworkStub.h"
#import "AppDelegate+Notifications.h"
#import "AppDelegate+BugFender.h"
#import "RAAlertManager+Extension.h"
#import "RASessionManager.h"
#import "RADateManager.h"
#import "RARideCacheManager.h"
#import "PersistenceManager.h"
#import "DriverManager.h"
#import "VersionManager.h"
#import "LoginViewController.h"
#import "LocationViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <BugfenderSDK/BugfenderSDK.h>
#import "AutoAvailabilityManager.h"
#import "RAEnvironmentManager.h"
#import "RideDriver-Swift.h"
@interface AppDelegate()

@property (strong, nonatomic) AppContainer *appContainer;

@end


@implementation AppDelegate

#pragma mark - App life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupGoogle];
    [self setupDefaultEnv];
    [[RADateManager sharedInstance] fetchCurrentDate:nil]; //Initialize TrueTime
    
    [self setupAppearance];
    self.appContainer = [AppContainer new];
    [AutoAvailabilityManager sharedManager].featuresService = self.appContainer.featuresService;
    [self setupNotifications];
    [self setupCarsData];
    [self setupBugFender];
    
    LocationService *locationService = [LocationService sharedService]; //Initizalize
    
    if ([RASessionManager shared].isSignedIn) {
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            [locationService startMonitoring];
        } else {
            [locationService start];
        }

    }

    // if the user looses connectivity to server, resynchronize client to server
    [[[RKObjectManager sharedManager] HTTPClient] setReachabilityStatusChangeBlock:^(AFRKNetworkReachabilityStatus status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkReachabilityStatusChanged
                                                            object:[NSNumber numberWithInt:status]
                                                          userInfo:nil];
    }];
    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable) {
        [RAAlertManager showBackgroundRefreshStatusNotAvailableAlert];
    }
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [VersionManager resetOptionalUpgradeDate];
    
    return YES;
}


/**
 Setup correct order: default env -> RestKit -> Stubs
 */
- (void)setupDefaultEnv {
    if ([[RAEnvironmentManager sharedManager] isEmptyEnvironment]) {
#ifdef QA
        [[RAEnvironmentManager sharedManager] setEnvironment:RAQAEnvironment];
#else
        [[RAEnvironmentManager sharedManager] setEnvironment:RAProdEnvironment];
#endif
    }
    
    [self setUpRestKit];
#ifdef QA
    [self setupAutomatedTestEnvironment];
    [self installNetworkStubsIfNeeded];
#endif
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    BFLog(@"applicationDidBecomeActive:");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.appContainer.featuresService fetch];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [ConfigurationManager needsReload];
    
    if ([RASessionManager shared].isSignedIn == NO) {
        [[LocationService sharedService] stop];
        return;
    }
    
    //Reload Driver Information on Load
    [[RASessionManager shared] reloadCurrentDriverWithCompletion:nil];
    
    if (self.locationViewController){
        if ([DriverManager shared].isDriverOnActiveRide) {
            [self.locationViewController autoSwipeManager];
        }
        
        DriverState driverState = [DriverManager shared].driverState;
        switch (driverState) {
            case AvailableDriverState:
            case OfflineDriverState:
            case InvalidDriverState: {
                [VersionManager checkNewVersionAvailableWithCompletion:^(BOOL shouldUpgrade, BOOL isMandatory) {
                    if (shouldUpgrade && isMandatory && driverState == AvailableDriverState) {
                        [[DriverManager shared] goOfflineWithCompletion:^(DriverState driverState, NSError *error) {}];
                    }
                }];
            }
                break;
            case GoingToPickUpDriverState:
            case ArrivingToPickUpDriverState:
            case OnTripDriverState:
            case AcceptingRequest:
                break;
        }
    }
    
    [[AutoAvailabilityManager sharedManager] stopMonitoringAvailability];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    BFLog(@"applicationDidEnterBackground:");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if ([RASessionManager shared].isSignedIn && [DriverManager shared].isDriverOnline) {
        [[LocationService sharedService] startMonitoring];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    
    //Start monitoring Availability (AutoGoOffline)
    if ([RASessionManager shared].isSignedIn && [DriverManager shared].driverState == AvailableDriverState) {
        [[AutoAvailabilityManager sharedManager] startMonitoringAvailability];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    BFLog(@"applicationWillTerminate:");
    [self goOfflineOnShutdown:application];
}

- (void)goOfflineOnShutdown:(UIApplication *)application {
    //FIX: RA-RA-3136 Required to go OFFLINE when quit app (swipe up)
    if ([DriverManager shared].driverState == AvailableDriverState)  {
        if (application) {
            __block UIBackgroundTaskIdentifier backgroundTask  = UIBackgroundTaskInvalid;
            backgroundTask = [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
                backgroundTask = UIBackgroundTaskInvalid;
            }];
            
            //Invalidate the task in the handler
            [[DriverManager shared] goOfflineWithCompletion:^(DriverState driverState, NSError * _Nullable error) {
                [application endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }];
        }
    }
    switch ([DriverManager shared].driverState) {
        case OfflineDriverState:
        case InvalidDriverState:
            break;
            
        case AvailableDriverState:
            [RAAlertManager showLocalNotificationWithTitle:@"The app has been terminated."
                                                   message:@" Thank you for driving!"
                                     andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateBackground andAlertActionTitle:nil]];
        case GoingToPickUpDriverState:
        case ArrivingToPickUpDriverState:
        case OnTripDriverState:
        case AcceptingRequest:
            [RAAlertManager showLocalNotificationWithTitle:@"The app has been terminated."
                                                   message:@"Please reopen app to continue driving."
                                     andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateBackground andAlertActionTitle:nil]];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL b = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
    
    LoginViewController *loginViewController = nil;
    
    UIViewController *rootVC = self.window.rootViewController;
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)rootVC;
        UIViewController *topVC = nav.topViewController;
        if ([topVC isKindOfClass:[LoginViewController class]]) {
            loginViewController = (LoginViewController*)topVC;
        }
    }
    
    //RA-9448
    if (loginViewController && [loginViewController fbLoginFailed]) {
        
        id lm = [[FBSDKLoginManager alloc] init];
        if ([lm respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
            if([lm application:application openURL:url sourceApplication:sourceApplication annotation:annotation]){
                [loginViewController continueLoginFromFBApp];
            }
        }
    }
    
    return b;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    BOOL b = [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                       annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
    LoginViewController *loginViewController = nil;
    
    UIViewController *rootVC = self.window.rootViewController;
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)rootVC;
        UIViewController *topVC = nav.topViewController;
        if ([topVC isKindOfClass:[LoginViewController class]]) {
            loginViewController = (LoginViewController*)topVC;
        }
    }

    //RA-9448
    if (loginViewController && [loginViewController fbLoginFailed]) {
        
        id lm = [[FBSDKLoginManager alloc] init];
        if ([lm respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
            if ([lm application:app openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]) {
                [loginViewController continueLoginFromFBApp];
            }
        }
    }
    
    return b;
}

#pragma mark - SplashScreen

- (void)showSplashScreen {
    [self goOfflineOnShutdown:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Background Refresh

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([RASessionManager shared].isSignedIn && [[RARideCacheManager sharedManager] hasCacheToFlush]) {
        [[RARideCacheManager sharedManager] flushAllRideCacheWithCompletion:^(BOOL success) {
            completionHandler(success ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
        }];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

@end
