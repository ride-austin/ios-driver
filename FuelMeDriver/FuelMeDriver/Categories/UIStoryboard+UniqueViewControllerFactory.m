//
//  UIStoryboard+UniqueViewControllerFactory.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/14/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "UIStoryboard+UniqueViewControllerFactory.h"
#import "ADInputViewController.h"
#import "ADMenuViewController.h"
#import "CarSelectionViewController.h"
#import "QueueViewController.h"
#import "RideRequestTypeViewController.h"
#import "SettingsViewController.h"
#import "WeeklyEarningsViewController.h"
@implementation UIStoryboard (UniqueViewControllerFactory)
+ (NSString*)storyboardNameForViewController:(NSString *)storyboardID {
    
    if ([storyboardID isEqualToString:RideRequestTypeViewController.className] ||
        [storyboardID isEqualToString:SettingsViewController.className] ||
        [storyboardID isEqualToString:WeeklyEarningsViewController.className]){
        return @"Main";
    }
    
    if ([storyboardID isEqualToString:QueueViewController.className]) {
        return @"AirportQueue";
    }
    
    if ([storyboardID isEqualToString:ADMenuViewController.className]) {
        return @"Admin";
    }
    
    if ([storyboardID isEqualToString:CarSelectionViewController.className]) {
        return @"DriverCars";
    }
    NSAssert(YES, @"storyboardNameForViewController:%@ returns nil", storyboardID);
    return nil;
}
+(UIViewController *)viewControllerForID:(NSString *)uniqueStoryboardID {
    NSString *storyboardName = [self storyboardNameForViewController:uniqueStoryboardID];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:uniqueStoryboardID];
}
@end
