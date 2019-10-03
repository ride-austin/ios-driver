//
//  RAFloatingMenuDataSource.h
//  RideDriver
//
//  Created by Roberto Abreu on 6/15/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseViewController.h"
#import "RideDriver-Swift.h"

@protocol RAFloatingMenuDelegate

- (void)findMyLocation;
- (void)showMessageViewWithRideID:(NSString *)rideID;
- (void)showUpgradePopupWithRideRequestUpgrade:(RideRequestUpgrade*)rideRequestUpgrade;

@end

@interface RAFloatingMenuDataSource : NSObject <LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate>

@property (weak, nonatomic) BaseViewController<RAFloatingMenuDelegate> *delegate;
@property (strong, nonatomic, readonly) NSArray<LiquidFloatingCell*> *floatingItems;

- (instancetype)initWithDelegate:(BaseViewController<RAFloatingMenuDelegate>*)delegate;
- (void)reloadItems;

@end
