//
//  RAFloatingMenuDataSource.m
//  RideDriver
//
//  Created by Roberto Abreu on 6/15/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAFloatingMenuDataSource.h"

#import "CarCategoriesManager.h"
#import "ConfigRideUpgrade.h"
#import "ConfigurationManager.h"
#import "DriverManager.h"
#import "PersistenceManager.h"
#import "RARideAPI.h"
#import "RARideUpgrade.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

@interface RAFloatingMenuDataSource ()

@property (strong, nonatomic, readwrite) NSArray<LiquidFloatingCell*> *floatingItems;

@end

@implementation RAFloatingMenuDataSource

- (instancetype)initWithDelegate:(BaseViewController<RAFloatingMenuDelegate>*)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)reloadItems {
    self.floatingItems = [self floatingItemsOptions];
}

- (NSArray<LiquidFloatingCell*> *)floatingItemsOptions {
    __weak RAFloatingMenuDataSource *weakSelf = self;
    NSMutableArray *items = [NSMutableArray array];
    
    //Find My Location
    LiquidFloatingLabelCell *myLocation = [[LiquidFloatingLabelCell alloc] initWithIcon:[UIImage imageNamed:@"findMyLocation"] name:[@"My Location" localized]];
    myLocation.accessibilityIdentifier = @"myLocationButton";
    myLocation.accessibilityLabel = @"myLocationButton";
    myLocation.isAccessibilityElement = YES;
    myLocation.tapAction = ^{
        [weakSelf.delegate findMyLocation];
    };
    [items addObject:myLocation];
    
    //Contact Support
    LiquidFloatingLabelCell *contactSupport = [[LiquidFloatingLabelCell alloc] initWithIcon:[UIImage imageNamed:@"support-icon"] name:[@"Contact Support" localized]];
    contactSupport.accessibilityIdentifier = @"contactSupport";
    contactSupport.accessibilityLabel = @"contactSupport";
    contactSupport.isAccessibilityElement = YES;
    contactSupport.tapAction = ^{
        [weakSelf.delegate showMessageViewWithRideID:nil];
    };
    [items addObject:contactSupport];
    DriverManager *driverManager = [DriverManager shared];
    if ([driverManager isDriverOnActiveRide] && driverManager.driverState != OnTripDriverState) {
        
        if (driverManager.rideDataModel && !driverManager.rideDataModel.rideRequestUpgrade) {
            ConfigRideUpgrade *configRideUpgrade = [ConfigurationManager shared].global.configRideUpgrade;
            RARideUpgrade *rideUpgrade = [configRideUpgrade rideUpgradeFromCarCategoryName:driverManager.rideDataModel.requestedCarType.carCategory];
            for (NSString *target in rideUpgrade.upgradeTargets) {
                
                //Driver should has the target category enabled
                if ([[RASessionManager shared].currentSession.userCarTypes containsObject:target] == NO) {
                    continue;
                }
                
                NSString *targetName = [NSString stringWithFormat:[@"Upgrade to %@" localized],target];
                UIImage *icon = [CarCategoriesManager carIconByCategoryName:target];
                
                LiquidFloatingLabelCell *targetItem = [[LiquidFloatingLabelCell alloc] initWithIcon:icon name:targetName];
                targetItem.accessibilityIdentifier = targetName;
                targetItem.accessibilityLabel = targetName;
                targetItem.isAccessibilityElement = YES;
                
                targetItem.tapAction = ^{
                    [weakSelf.delegate showHUD];
                    [RARideAPI requestUpgradeWithCategoryTarget:target andCompletion:^(NSString *message, NSError *error) {
                        [weakSelf.delegate hideHUD];
                        if (!error) {
                            [driverManager.rideDataModel upgradeRequestWithTarget:target];
                            [weakSelf.delegate showUpgradePopupWithRideRequestUpgrade:driverManager.rideDataModel.rideRequestUpgrade];
                        } else {
                            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                        }
                    }];
                };
                [items addObject:targetItem];
            }
        } else if (driverManager.rideDataModel && driverManager.rideDataModel.rideRequestUpgrade.status == UpgradeRequested) {
            UIImage *icon = [CarCategoriesManager carIconByCategoryName:driverManager.rideDataModel.rideRequestUpgrade.target];
            LiquidFloatingLabelCell *pendingUpgrade = [[LiquidFloatingLabelCell alloc] initWithIcon:icon name:[@"Upgrade Requested" localized]];
            pendingUpgrade.accessibilityIdentifier = @"Upgrade Requested";
            pendingUpgrade.accessibilityLabel = @"Upgrade Requested";
            pendingUpgrade.isAccessibilityElement = YES;
            pendingUpgrade.tapAction = ^{
                RideRequestUpgrade *upgradeRequested = driverManager.rideDataModel.rideRequestUpgrade;
                [weakSelf.delegate showUpgradePopupWithRideRequestUpgrade:upgradeRequested];
            };
            [items addObject:pendingUpgrade];
        }
        
    }
    
    return items;
}

#pragma mark - DataSource & Delegate

- (NSInteger)numberOfCells:(LiquidFloatingActionButton *)liquidFloatingActionButton {
    return self.floatingItems.count;
}

- (LiquidFloatingCell *)cellForIndex:(NSInteger)index {
    return self.floatingItems[index];
}

- (void)liquidFloatingActionButton:(LiquidFloatingActionButton *)liquidFloatingActionButton didSelectItemAtIndex:(NSInteger)index {
    [liquidFloatingActionButton close];
}

@end
