//
//  BaseViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 12/01/14.
//  Copyright (c) 2014 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

#import "NSObject+className.h"
#import "NavigationAppUtil.h"
#import "SMessageViewController.h"
#import "UIAlertController+Window.h"
#import "UIDevice+VersionCheck.h"
#import "WebViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    static NSString *backTitle = nil;
    if (!backTitle) {
        backTitle = @"";
        if ([UIDevice currentDevice].systemMajorVersion < 7) {
            backTitle = @"Back";
        }
    }
    
    // We want a white nav bar.
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        backButton.tintColor = [UIColor colorNamed:@"menuButtonColor"];
    } else {
        backButton.tintColor = [UIColor blackColor];
    }
    
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)dealloc {
    DBLog(@"deallocated %@", [self className]);
}

- (void)configureAllTapsWillDismissKeyboard {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

- (void)addNotificationObserver:(SEL)selector name:(NSString *)name {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:name object:nil];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - HUD

- (void)hudWasHidden {
   [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Launch Browser

- (void)launchBrowser:(NSString *)url title:(NSString *)title {
    WebViewController *webViewController = [[WebViewController alloc] initWithUrl:[NSURL URLWithString:url]
                                                                         urlTitle:title];
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - Instantiate a View Controller

- (UIViewController *) createViewController:(NSString *)identifier {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:identifier];
}

- (UIViewController *)createViewControllerFromStoryboard:(NSString *)storyboardName withIdentifier:(NSString *)identifier {
    return [[UIStoryboard storyboardWithName:storyboardName bundle:NULL] instantiateViewControllerWithIdentifier:identifier];
}

#pragma mark - Support Message View Controller

- (void)showMessageViewWithRideID:(NSString  * _Nullable)rideID {
    SMessageViewController *vc = [[UIStoryboard storyboardWithName:@"Support" bundle:nil] instantiateViewControllerWithIdentifier:[SMessageViewController className]];
    vc.rideID = rideID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)needHelp:(id)sender {
    [self showMessageViewWithRideID:nil];
}

#pragma mark - Navigation App

- (void)showAlertToInstallNavigationApp:(NavigationApp)navigationApp {
    UIAlertAction *actionGo = [UIAlertAction actionWithTitle:@"Install" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NavigationAppUtil itunesUrl:navigationApp]];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *av = [UIAlertController alertControllerWithTitle:[ConfigurationManager appName]
                                                                message:[NSString stringWithFormat:@"Please install %@ Application for navigation.",[NavigationAppUtil nameApp:navigationApp]]
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [av addAction:actionGo];
    [av addAction:actionCancel];
    [self presentViewController:av animated:YES completion:nil];
}

@end
