//
//  SplashViewController.m
//  FuelMe
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "SplashViewController.h"

#import "AppDelegate+Extensions.h"
#import "AppDelegate.h"
#import "AssetCityManager.h"
#import "ConfigurationManager.h"
#import "ErrorReporter.h"
#import "FlatButton+StyleFacade.h"
#import "LocationService.h"
#import "LocationViewController.h"
#import "NSString+Utils.h"
#import "RADateManager.h"
#import "RAEnvironmentDefines.h"
#import "RASessionManager.h"
#import "RideDriver-Swift.h"
#import "RideDriverConstants.h"
#import "UIImage+animatedGIF.h"
#import "UIView+Animation.h"
#import "VersionManager.h"
#import "RAEnvironmentManager.h"
#import "RAAlertManager.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface SplashViewController()

@property (nonatomic, strong) LocationViewController *locationViewController;

@property (nonatomic) UIAlertController *internetAlert;
@property (nonatomic) BOOL wasConnected;

@property (nonatomic) NSString *oldEnv;

- (void)handleReachabilityStatusChange:(AFRKNetworkReachabilityStatus)status;

@end

@implementation SplashViewController

- (LocationViewController *)locationViewController {
    @synchronized (self) {
        //First try to get locationVC from NavigationStack
        if (!_locationViewController) {
            _locationViewController = [((AppDelegate*)[UIApplication sharedApplication].delegate) locationViewController];
        }
        
        //If there isn't any locationVC in Stack create a new one
        if (!_locationViewController) {
            _locationViewController = (LocationViewController*)[self createViewController:@"LocationViewController"];
        }
        
        return _locationViewController;
    }
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureAccessibility];
    self.wasConnected = YES;
    
    //Configure UI
    self.splashImage.alpha = 0;
    self.ivWhiteLogo.alpha = 0;
    self.version.text = [RAEnvironmentManager sharedManager].version;
    [self hideAuthViewAndStartLoading];
    
    //Configure Segmented control
    self.segmentControl.selectedSegmentIndex = [RAEnvironmentManager sharedManager].environment;
    self.segmentControl.hidden = YES;
#ifdef QA
    self.segmentControl.hidden = NO;
#endif
    
    [self addObservers];
    [self configureButtonsStyle];
}

- (void)configureButtonsStyle {
    [self.loginButton applyLoginStyle];
    [self.createButton applyRegisterStyle];
}

- (void)configureAccessibility {
    self.view.accessibilityIdentifier        = @"splashView";
    self.splashImage.accessibilityIdentifier = @"splashBgImage";
    self.ivWhiteLogo.accessibilityIdentifier = @"splashLogoImage";
    self.version.accessibilityIdentifier     = @"splashVersionLabel";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self updateUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Authentication

- (void)updateUI {
    __weak SplashViewController *weakSelf = self;
    [self updateUIByCityWithCompletion:^{
        [weakSelf tryAuthenticate];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          [weakSelf tryAuthenticate];
                                                      }];
    }];
}

- (void)tryAuthenticate {
    if (![[NetworkManager sharedInstance] isNetworkReachable]) {
        return;
    }
    
    BOOL authenticated = [RASessionManager shared].isSignedIn;
    
    __weak SplashViewController *weakSelf = self;
    [VersionManager checkNewVersionAvailableWithCompletion:^(BOOL shouldUpgrade, BOOL isMandatory) {
        BOOL mustUpgrade = shouldUpgrade && isMandatory;
        if (!authenticated) {
            [VersionManager showAlertIfNeeded];
            if (!mustUpgrade) {
                [self showAuthViewAndStopLoading];
            }
            return;
        }
        
        [RAActiveDriversAPI getActiveDriverCurrentWithCompletion:^(RAActiveDriver * _Nullable activeDriver, NSError * _Nullable error) {
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                [weakSelf continueAuthentication];
            } else {
                if (activeDriver) {
                    switch (activeDriver.status) {
                        case RAActiveDriverStatusRiding:
                        case RAActiveDriverStatusRequested:
                            [weakSelf continueAuthentication];
                            return;
                        default:
                            //Fallback: ActiveDriver not in Ride
                            break;
                    }
                }
                
                [VersionManager showAlertIfNeeded];
                if (!mustUpgrade) {
                    [weakSelf continueAuthentication];
                }
            }
        }];
    }];
}

- (void)continueAuthentication {
    //User is authenticated and has Internet connection
    //Check if the user granted the Location Authorization
    if ([LocationService hasLocationAuthorization]) {
        if ([self isVisible]) {
            [self authenticate];
        }
    } else {
        [self showLocationAuthorizationAlert];
    }
}

- (void)showLocationAuthorizationAlert {
    if([PersistenceManager hasLocationsSettings]) {
        
        UIAlertController *locationDisabledAlert = [UIAlertController alertControllerWithTitle:[@"RideDriver needs your location!" localized] message:[@"To re-enable, please go to Settings and turn on Location Service." localized] preferredStyle:UIAlertControllerStyleAlert];
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [locationDisabledAlert addAction:[UIAlertAction actionWithTitle:[@"Go to Settings" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:url];
            }]];
            
            [locationDisabledAlert addAction:[UIAlertAction actionWithTitle:[@"Cancel" localized] style:UIAlertActionStyleCancel handler:nil]];
        } else {
            [locationDisabledAlert addAction:[UIAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:nil]];
        }
        
        [self presentViewController:locationDisabledAlert animated:YES completion:nil];
    } else {
        [PersistenceManager saveLocationSettings:YES];
    }
}

- (void)authenticate {
    __weak SplashViewController *weakSelf = self;
    [[RASessionManager shared] reloadCurrentDriverWithCompletion:^(RADriverDataModel *driver, NSError *error) {
        if (!error) {
            
            //Refresh Current Date if needed
            [[RADateManager sharedInstance] fetchCurrentDate:^(NSDate *date, NSError *error) {
                [[DriverManager shared] synchronizeStateSendingLocalCacheIfNeeded:^(DriverState state, RARideDataModel * _Nullable ride) {
                    if(![weakSelf isVisible]){
                        return;
                    }
                    
                    [self.locationViewController initializeSurgeAreaManagerWithCompletion:^{
                        [weakSelf.navigationController setViewControllers:@[weakSelf,self.locationViewController] animated:YES];
                    }];
                }];
            }];
            
        } else {
            if ([ErrorReporter reportConnectivityError:error] == NO) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
            }
            
            [self showAuthViewAndStopLoading];
        }
    }];
}

#pragma mark - Observers

- (IBAction)doRegister:(FlatButton *)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[@"REGISTER" localized] message:[NSString stringWithFormat:[@"Please register as a driver from the %@ app" localized], [ConfigurationManager appName]] preferredStyle:UIAlertControllerStyleAlert];
    
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
- (void)addObservers {
    __weak SplashViewController *weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNetworkReachabilityStatusChanged
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^ (NSNotification *notification) {
                                                      NSNumber *statusNumber = (NSNumber *)notification.object;
                                                      AFRKNetworkReachabilityStatus status = [statusNumber intValue];
                                                      [weakSelf handleReachabilityStatusChange:status];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNetworkConnectivityLost
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^ (NSNotification *notification) {
                                                      [weakSelf connectivityLost];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidChangeCurrentCityType
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [weakSelf updateUIByCityWithCompletion:nil];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - Handler Reachability

- (void)handleReachabilityStatusChange:(AFRKNetworkReachabilityStatus)status {
    switch (status) {
        case AFRKNetworkReachabilityStatusNotReachable: {
            if (self.internetAlert) {
                return;
            }
            
            BFLogWarn(@"Internet Offline");
            self.internetAlert = [RAAlertManager showAlertWithTitle:[@"Internet Offline" localized] message:[@"Your internet appears to be offline. Please connect to the internet to continue." localized] options:[RAAlertOption optionWithState:StateAll andShownOption:Overlap]];
            self.wasConnected = NO;
            break;
        }
        case AFRKNetworkReachabilityStatusReachableViaWiFi:
        case AFRKNetworkReachabilityStatusReachableViaWWAN: {
            
            __weak SplashViewController *weakSelf = self;
            [self.internetAlert dismissViewControllerAnimated:NO completion:^{
                weakSelf.internetAlert = nil;
            }];
            
            //Try to authenticate when the Internet connection available
            if ([self isVisible] && !self.wasConnected) {
                [self updateUI];
            }
            
            self.wasConnected = YES;
            BFLog(@"Internet Reachable");
            break;
        
        }
        case AFRKNetworkReachabilityStatusUnknown: {
            BFLogWarn(@"Internet Reachability Unknown");
            break;
        }
    }
}

- (void)connectivityLost {
    [self showAuthViewAndStopLoading];
    [RAAlertManager showAlertWithTitle:[@"Network Connectivity Lost" localized]
                             message:[@"We are unable to connect to server at this moment. Please try again later or Contact Support." localized]
                             options:[RAAlertOption optionWithState:StateActive]];
}

#pragma mark - Enviroment

- (IBAction)changeEnv:(id)sender {
    UISegmentedControl *segmentControl = (UISegmentedControl*)sender;
    RAEnvironment selectedEnv = (RAEnvironment)segmentControl.selectedSegmentIndex;
    switch (selectedEnv) {
        case RAQAEnvironment:
        case RAStageEnvironment:
            self.oldEnv = [RAEnvironmentManager sharedManager].serverUrl;
            [self setEnv:selectedEnv];
            break;
        case RACustomEnvironment: {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[ConfigurationManager appName] message:@"Please enter in server:" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.text = [RAEnvironmentManager sharedManager].serverUrl;
            }];
            
            UIAlertAction *customAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *textField = [alert.textFields firstObject];
                self.oldEnv = [RAEnvironmentManager sharedManager].serverUrl;
                [[RAEnvironmentManager sharedManager] setCustomServerURL:textField.text];
                [self setEnv:RACustomEnvironment];
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:customAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
            
        case RAProdEnvironment: {
        default:
            self.oldEnv = [RAEnvironmentManager sharedManager].serverUrl;
            [self setEnv:RAProdEnvironment];
        }
    }
}

- (void)setEnv:(RAEnvironment)env {
    [[RAEnvironmentManager sharedManager] setEnvironment:env];
    #ifdef QA
    NSString *message = [NSString stringWithFormat:@"from:\n%@\nto:\n%@",self.oldEnv, [RAEnvironmentManager sharedManager].serverUrl];
    
    RAAlertOption *option = [RAAlertOption optionWithState:StateActive
                                            andShownOption:Overlap];
    [option addAction:[RAAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        #ifndef AUTOMATION
        exit(1);
        #endif
    }]];
    [RAAlertManager showAlertWithTitle:@"RESTART REQUIRED" message:message options:option];
    #endif
}

#pragma mark - City Helper Functions

- (void)updateUIByCityWithCompletion:(void(^)(void))completion {
    
    __weak SplashViewController *weakSelf = self;
    RAGeneralInfo *config = [ConfigurationManager shared].global.generalInfo;
    
    //show Logo image with fade in animation
    [self.ivWhiteLogo sd_setImageWithURL:config.logoURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image == nil) {
            image = [AssetCityManager logoWhiteCurrentCity];
        }
        weakSelf.ivWhiteLogo.image = image;
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakSelf.ivWhiteLogo.alpha = 1;
        } completion:nil];
        
    }];
    
    //Apply buttons style
    self.segmentControl.backgroundColor = [UIColor clearColor];
    self.segmentControl.tintColor       = [AssetCityManager colorCurrentCity:Border];
    
    [self.loginButton applyLoginStyle];
    
    //Update splash background
    [self.splashImage sd_setImageWithURL:config.splashURL
                        placeholderImage:nil
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   if (image == nil) {
                                       image = [AssetCityManager defaultSplash];
                                   }
                                   weakSelf.splashImage.image = image;
                                   [UIView animateWithDuration:1.0
                                                         delay:0
                                                       options:UIViewAnimationOptionCurveEaseInOut
                                                    animations:^{
                                       weakSelf.splashImage.alpha = 1;
                                                    } completion:^(BOOL completed){
                                                        if (completion) {
                                                            completion();
                                                        }
                                                    }];
                        }];
    
    
}

#pragma mark - Loaders

- (void)showAuthViewAndStopLoading {
    self.locationViewController = nil;
    
    [self.authContainerView showAnimated:^(BOOL finished) {
        [self.activityView stopAnimating];
    }];
}

- (void)hideAuthViewAndStartLoading {
    [self.authContainerView setAlpha:0.0f];
    [self.activityView startAnimating];
}

@end
