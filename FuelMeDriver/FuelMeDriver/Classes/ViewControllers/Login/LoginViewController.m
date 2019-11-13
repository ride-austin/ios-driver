//
//  LoginViewController.m
//  RideAustin
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "LoginViewController.h"

#import "ErrorReporter.h"
#import "ForgotPasswordViewController.h"
#import "LocationViewController.h"
#import "NSString+Utils.h"
#import "NSString+Valid.h"
#import "PaddedTextField.h"
#import "RADateManager.h"
#import "RASessionManager.h"
#import "SplashViewController.h"
#import "UITextField+Valid.h"
#import "VersionManager.h"
#import "RAAlertManager.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController ()

@property (nonatomic) BOOL fbLoginFailed;

- (NSArray *)validate;

@end

@implementation LoginViewController

#pragma mark - Lifecycle VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fbLoginFailed = NO;
    
    [super configureAllTapsWillDismissKeyboard];
    [self setupDesign];
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)setupDesign {
    self.title = @"Sign In".localizedCapitalizedString;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController setNavigationBarHidden:NO];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[@"DONE" localized] style:UIBarButtonItemStylePlain target:self action:@selector(doLogin)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    //Add Left Paddings to fields
    [self.emailTextField setLeftPaddingWithSpace:15];
    [self.passwordTextField setLeftPaddingWithSpace:15];
}

#pragma mark - IBActions

- (IBAction)doFacebook:(id)sender {
    __weak LoginViewController *weakself = self;
    [[RASessionManager shared] loginWithFacebookFromViewController:self andCompletion:^(RADriverDataModel * _Nullable driver, NSError * _Nullable error) {
        [weakself hideHUD];
        if (error) {
            if (error.code == 202) {
                [weakself showSignupFromRiderApp];
            } else {
                [ErrorReporter recordError:error withDomainName:FBLogin];
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
            }
        } else if (driver) {
            [weakself didFinishAuthentication];
        } else {
            //error == nil && driver == nil must be cancelled
        }
    }];
}

- (void)doLogin {
    self.fbLoginFailed = NO;
    [self.view endEditing:YES];
    
    NSArray *errors = [self validate];
    if (errors) {
        NSString *errorMessage = errors.firstObject;
        [RAAlertManager showErrorWithAlertItem:errorMessage andOptions:[RAAlertOption optionWithState:StateActive andShownOption:Overlap]];
        [[errors lastObject] becomeFirstResponder];
    } else {
        __weak LoginViewController *weakSelf = self;
        [self showHUD];
        [[RASessionManager shared] loginWithUsername:self.emailTextField.text password:self.passwordTextField.text andCompletion:^(RADriverDataModel *driver, NSError *error) {
             [weakSelf hideHUD];
             if (error) {
                 [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
             } else {
                 [weakSelf didFinishAuthentication];
             }
        }];
    }
}

- (void)continueLoginFromFBApp{
    if ([RASessionManager shared].isSignedIn) {
        return;
    }
}

- (void)didFinishAuthentication {
    __weak LoginViewController *weakself = self;
    [self showHUD];
    //Refresh Current Date if needed
    [[RADateManager sharedInstance] fetchCurrentDate:^(NSDate *date, NSError *error) {
        [[DriverManager shared] synchronizeStateSendingLocalCacheIfNeeded:^(DriverState state, RARideDataModel * _Nullable ride) {
            LocationViewController *locationViewController = (LocationViewController*)[weakself createViewController:LocationViewController.className];
            [locationViewController initializeSurgeAreaManagerWithCompletion:^{
                [weakself hideHUD];
                
                if (!locationViewController) {
                    BFLogErr(@"LocationViewController was dealloc while finish authentication");
                }
                
                if (![weakself.navigationController viewControllers].firstObject) {
                    BFLogErr(@"SplashViewController was dealloc while finish authentication");
                }
                
                UIViewController *splashViewController = [weakself createViewController:SplashViewController.className];
                [weakself.navigationController setViewControllers:@[splashViewController,locationViewController] animated:YES];
            }];
        }];
    }];
    
    [VersionManager checkNewVersionAvailableWithCompletion:^(BOOL shouldUpgrade, BOOL isMandatory) {
        [VersionManager resetOptionalUpgradeDate];
        [VersionManager showAlertIfNeeded];
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self doLogin];
    }
    return YES;
}

#pragma mark - Helpers
- (NSArray*)validate {
    if([self.emailTextField isEmpty]) {
        return @[[@"Please enter your email address." localized], self.emailTextField];
    } else {
        //RA-1133: Implemeted validation category
        if (![self.emailTextField isValidEmail]) {
            return @[[@"Please enter a valid email address." localized], self.emailTextField];
        }
    }
    
    if([self.passwordTextField isEmpty]) {
        return @[[@"Please enter a password." localized], self.passwordTextField];
    } else {
        //RA-1133: Implemeted validation category
        if (![self.passwordTextField isValidPassword]) {
            return @[ [NSString stringWithFormat:[@"Your password needs to be at least %li characters long." localized], (long)kMinPasswordLength], self.passwordTextField ];
        }
    }
    
    return nil;
}

- (void)showSignupFromRiderApp {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[@"SIGN IN FAILED" localized] message:[NSString stringWithFormat:[@"Please register as a driver from the %@ app first" localized], [ConfigurationManager appName]] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:[@"Cancel" localized] style:UIAlertActionStyleCancel handler:nil]];
    
    NSURL *urlApp = [NSURL URLWithString:@"rideaustin://driverSignup"];
    NSURL *urlAppLink = [NSURL URLWithString:@"https://itunes.apple.com/us/app/ride-austin-non-profit-tnc/id1116489847?ls=1&mt=8"];
    if ([[UIApplication sharedApplication] canOpenURL:urlApp]) {
        [alert addAction:[UIAlertAction actionWithTitle:[@"Open RideAustin App" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:urlApp];
        }]];
    } else {
        [alert addAction:[UIAlertAction actionWithTitle:[@"Install RideAustin App" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:urlAppLink];
        }]];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
