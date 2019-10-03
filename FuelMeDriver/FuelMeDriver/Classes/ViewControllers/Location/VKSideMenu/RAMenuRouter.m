//
//  RAMenuRouter.m
//  RideDriver
//
//  Created by Roberto Abreu on 19/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAMenuRouter.h"

#import "ADInputViewController.h"
#import "LocationViewController.h"
#import "NSObject+className.h"
#import "QueueViewController.h"
#import "RideRequestTypeViewController.h"
#import "SettingsViewController.h"
#import "WeeklyEarningsViewController.h"
#import "RAAlertManager.h"

@interface RAMenuRouter ()

+ (void)configureTargetController:(UIViewController *)targetController
                   fromController:(UIViewController *)fromController
                     withMenuItem:(RAMenuItem *)menuItem;

+ (BOOL)shouldShowMenuItem:(RAMenuItem *)menuItem;

@end

@implementation RAMenuRouter

+ (void)routeMenuItem:(RAMenuItem *)menuItem fromController:(BaseViewController *)controller {
    
    if (![RAMenuRouter shouldShowMenuItem:menuItem]) {
        DBLog(@"MenuItem with title %@ not allowed",menuItem.title);
        return;
    }
    
    if (!menuItem.storyboardIdentifier) {
        DBLog(@"StoryBoard Identifier unknown");
        return;
    }
    
    UIViewController *targetController = [[UIStoryboard storyboardWithName:menuItem.storyboardIdentifier bundle:nil] instantiateViewControllerWithIdentifier:menuItem.targetClassIdentifier];
    
    if (!targetController) {
        DBLog(@"**Could not get TargetController");
        return;
    }
    
    [RAMenuRouter configureTargetController:targetController fromController:(BaseViewController*)controller withMenuItem:menuItem];
    
    switch (menuItem.behaviour) {
        case Push:
            [RAMenuRouter pushController:targetController fromController:controller];
            break;
        case Present:
            [RAMenuRouter presentController:targetController fromController:controller];
        default:
            break;
    }
}

+ (void)pushController:(UIViewController *)toController fromController:(BaseViewController *)fromController {
    if (fromController.navigationController) {
        [fromController.navigationController pushViewController:toController animated:YES];
    }
}

+ (void)presentController:(UIViewController *)toController fromController:(BaseViewController *)fromController {
    [fromController presentViewController:toController animated:YES completion:nil];
}

+ (void)configureTargetController:(UIViewController *)targetController
                   fromController:(UIViewController *)fromController
                     withMenuItem:(RAMenuItem *)menuItem {
    if ([menuItem.targetClassIdentifier isEqualToString:QueueViewController.className] && [menuItem.objectContext isMemberOfClass:[QueueZone class]]) {
        QueueViewController *queueViewController = (QueueViewController*)targetController;
        queueViewController.queue = menuItem.objectContext;
        ((LocationViewController*)fromController).queueEventsDelegate = queueViewController;
    }
}

+ (BOOL)shouldShowMenuItem:(RAMenuItem *)menuItem {
    if ([menuItem.targetClassIdentifier isEqualToString:RideRequestTypeViewController.className] && [DriverManager shared].isDriverOnActiveRide) {
        [RAAlertManager showAlertWithTitle:[ConfigurationManager appName]
                                 message:@"You cannot change ride type during trip."];
        return NO;
    }
    
    return YES;
}

@end
