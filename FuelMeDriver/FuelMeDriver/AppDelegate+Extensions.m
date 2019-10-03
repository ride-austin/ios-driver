//
//  AppDelegate+Extensions.m
//  RideDriver
//
//  Created by Roberto Abreu on 16/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate+Extensions.h"
#import "LocationViewController.h"
#import "ErrorReporter.h"

@implementation AppDelegate (Extensions)

- (UINavigationController *)navigationController {
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        return nav;
    } else {
        NSString *domainName = [NSString stringWithFormat:@"RootNavigationControllerReplacedWith-%@",NSStringFromClass([nav class])];
        NSError *error = [NSError errorWithDomain:domainName code:UIRootNavigationControllerReplaced userInfo:nil];
        [ErrorReporter recordError:error withDomainName:UIRootNavigationControllerReplaced andCustomName:domainName];
        NSAssert(false, domainName);
        return nil;
    }
}

- (LocationViewController *)locationViewController {
    UINavigationController *navController = self.navigationController;
    if (!navController) {
        return nil;
    }
    
    LocationViewController *locationViewController = nil;
    for (UIViewController *tmpController in navController.viewControllers) {
        if ([tmpController isKindOfClass:[LocationViewController class]]) {
            locationViewController = (LocationViewController*)tmpController;
            break;
        }
    }
    
    return locationViewController;
}

@end
