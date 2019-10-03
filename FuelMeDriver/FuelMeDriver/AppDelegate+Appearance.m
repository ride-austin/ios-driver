//
//  AppDelegate+Appearance.m
//  RideDriver
//
//  Created by Roberto Abreu on 15/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate+Appearance.h"

@implementation AppDelegate (Appearance)

- (void)setupAppearance {
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:7.0/255.0 green:13.0/255.0 blue:22.0/255.0 alpha:1.0]];
    
    UIFont *font = [UIFont fontWithName:@"Montserrat-Light" size:19];
    UIColor *textColor = [UIColor colorWithRed:44.0/255.0 green:50.0/255.0 blue:60.0/255.0 alpha:1.0];
    
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:font forKey:NSFontAttributeName];
    [titleBarAttributes setValue:textColor forKey:NSForegroundColorAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
    font = [UIFont fontWithName:@"Montserrat-Regular" size:15];
    UIColor *disabledTextColor = [UIColor colorWithRed:145.0/255.0 green:148.0/255.0 blue:152.0/255.0 alpha:1.0];
    UIColor *enabledTextColor = [UIColor colorWithRed:2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1];
    
    NSMutableDictionary *barButtonDisabledAttributes = [NSMutableDictionary dictionaryWithDictionary:[[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateDisabled]];
    [barButtonDisabledAttributes setValue:font forKey:NSFontAttributeName];
    [barButtonDisabledAttributes setValue:disabledTextColor forKey:NSForegroundColorAttributeName];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonDisabledAttributes forState:UIControlStateDisabled];
    
    NSMutableDictionary *barButtonEnabledAttributes = [NSMutableDictionary dictionaryWithDictionary:[[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal]];
    [barButtonEnabledAttributes setValue:font forKey:NSFontAttributeName];
    [barButtonEnabledAttributes setValue:enabledTextColor forKey:NSForegroundColorAttributeName];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonEnabledAttributes forState:UIControlStateNormal];
}

@end
