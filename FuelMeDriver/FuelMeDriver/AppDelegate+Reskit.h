//
//  AppDelegate+Reskit.h
//  RideDriver
//
//  Created by Roberto Abreu on 14/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "UIDevice+Model.h"
#import "UIDevice+Unique.h"
#import <RestKit/RestKit.h>

@interface AppDelegate (RestKit)

+ (RKObjectManager *)objectManager; //A new object manager, not shared one.
- (void)setUpRestKit;

@end
