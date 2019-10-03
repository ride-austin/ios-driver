//
//  RAUpgradePopup.h
//  RideDriver
//
//  Created by Roberto Abreu on 6/14/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RideRequestUpgrade.h"

@class RAUpgradePopup;

@protocol RAUpgradePopupDelegate

- (void)didTapCancel:(RAUpgradePopup*)upgradePopup;
- (void)didTapClose:(RAUpgradePopup*)upgradePopup;

@end

@interface RAUpgradePopup : UIView

@property (nonatomic, weak) id<RAUpgradePopupDelegate> delegate;

+ (instancetype)upgradePopupWithTargetName:(NSString*)targetName status:(UpgradeStatus)status andDelegate:(id<RAUpgradePopupDelegate>)delegate;

- (void)updateToStatus:(UpgradeStatus)upgradeState;
- (void)show;
- (void)dismiss;

@end
