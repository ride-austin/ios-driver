//
//  RASideMenu.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VKSideMenu.h"

@class QueueZone;
@class ConfigGlobal, RADriverDataModel; //exposed for testing

@interface RASideMenu : NSObject

@property (nonatomic, strong) VKSideMenu * menu;
@property (nonatomic, readonly) NSMutableArray *menuItems; //exposed for testing

+ (instancetype)configureWithPresenter:(UIViewController *)presenter;
- (void)show;
- (void)updateMenuItemsWithConfig:(ConfigGlobal *)global andDriver:(RADriverDataModel *)currentDriver; //exposed for testing

@end
