//
//  AppDelegate+NetworkStub.h
//  RideDriver
//
//  Created by Roberto Abreu on 4/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (NetworkStub)

- (void)setupAutomatedTestEnvironment;
- (void)installNetworkStubsIfNeeded;

@end
