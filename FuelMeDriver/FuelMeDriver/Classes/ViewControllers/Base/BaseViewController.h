//
//  BaseViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 7/25/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConfigurationManager.h"
#import "DriverManager.h"
#import "NSObject+className.h"
#import "NetworkManager.h"
#import "PersistenceManager.h"
#import "RAPhotoPickerControllerManager.h"
#import "RARideDataModel.h"
#import "RASessionManager.h"
#import "RideDriverEnums.h"
#import "SoundManager.h"
#import "UIImage+Ride.h"
#import "UIViewController+Utils.h"
#import "UIViewController+progressHUD.h"

#import <BugfenderSDK/BugfenderSDK.h>

@interface BaseViewController : UIViewController

NS_ASSUME_NONNULL_BEGIN

- (void)configureAllTapsWillDismissKeyboard;
- (void)addNotificationObserver:(SEL)selector name:(NSString*)name;

#pragma mark - Utility controller
- (void)launchBrowser:(NSString*)url title:(NSString*) title;
- (UIViewController*)createViewController:(NSString*)identifier;
- (UIViewController*)createViewControllerFromStoryboard:(NSString*)storyboardName withIdentifier:(NSString*)identifier;

#pragma mark - Support Message View Controller
/**
 *  will push SMessageViewController and will pop after sending request
 *  always sending driver's registered city id
 */
- (void)showMessageViewWithRideID:(NSString * _Nullable)rideID;


#pragma mark - Need Help

- (IBAction)needHelp:(id)sender;

#pragma mark - Navigation App
- (void)showAlertToInstallNavigationApp:(NavigationApp)navigationApp;

NS_ASSUME_NONNULL_END

@end
 
