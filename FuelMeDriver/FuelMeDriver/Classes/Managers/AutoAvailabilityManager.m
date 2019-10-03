//
//  AutoAvailabilityManager.m
//  RideDriver
//
//  Created by Roberto Abreu on 8/27/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AutoAvailabilityManager.h"

#import "ConfigurationManager.h"
#import "DriverManager.h"
#import "PopupManagerDefines.h"
#import "RAAlertManager+Extension.h"
#import "RideDriver-Swift.h"

@implementation AutoAvailabilityManager

+ (instancetype)sharedManager {
    static AutoAvailabilityManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AutoAvailabilityManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)startMonitoringAvailability {
    [self stopMonitoringAvailability];
    
    AutoGoOfflineConfig *configAutoGoOffline = self.featuresService.autoGoOfflineValue;
    if (configAutoGoOffline.enabled) {
        [self performSelector:@selector(showAvailabilityNotification) withObject:nil afterDelay:configAutoGoOffline.backgroundWarningPeriod];
        [self performSelector:@selector(goOfflineWithHandler) withObject:nil afterDelay:configAutoGoOffline.backgroundMaximumPeriod];
    }
}

- (void)stopMonitoringAvailability {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - Actions

- (void)showAvailabilityNotification {
    if ([DriverManager shared].driverState == AvailableDriverState) {
        AutoGoOfflineConfig *configAutoGoOffline = self.featuresService.autoGoOfflineValue;
        [RAAlertManager showLocalNotificationWithTitle:@"" message:configAutoGoOffline.warningMessage andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateBackground andCategoryIdentifier:kLocalNotificationAvailabilityId]];
    }
}

- (void)goOfflineWithHandler {
        [[DriverManager shared] goOfflineWithCompletion:^(DriverState driverState, NSError * _Nullable error) {
            if (!error) {
                // its better to always show local notification when driver goes offline in the background. DriverManager should handle this
                AutoGoOfflineConfig *configAutoGoOffline = self.featuresService.autoGoOfflineValue;
                [RAAlertManager showAutoOfflineLocalNotification: configAutoGoOffline.offlineBackgroundMessage];
            }
        }];
}

@end
