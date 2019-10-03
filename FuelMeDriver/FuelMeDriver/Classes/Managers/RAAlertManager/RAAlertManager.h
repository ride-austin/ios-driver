//
//  RAAlertManager.h
//  Ride
//
//  Created by Roberto Abreu on 15/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertController+Utility.h"
#import "RAAlertItem.h"
#import "RAAlertConstant.h"
#import "RAAlertOption.h"
#import "RAAlertNotificationOption.h"

@interface RAAlertManager : NSObject

+ (UIAlertController*)showAlertWithTitle:(NSString*)title message:(NSString*)message;
+ (UIAlertController*)showAlertWithTitle:(NSString*)title message:(NSString*)message options:(RAAlertOption*)option;

+ (UIAlertController*)showErrorWithAlertItem:(id<RAAlertItem>)alertItem andOptions:(RAAlertOption*)options;

+ (void)showLocalNotificationWithTitle:(NSString*)title message:(NSString*)message andNotificationOption:(RAAlertNotificationOption*)option;

+ (void)resetAlerts;

@end
