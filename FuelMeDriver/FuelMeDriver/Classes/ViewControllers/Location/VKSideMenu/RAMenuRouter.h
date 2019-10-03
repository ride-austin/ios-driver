//
//  RAMenuRouter.h
//  RideDriver
//
//  Created by Roberto Abreu on 19/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAMenuItem.h"

@class BaseViewController;

@interface RAMenuRouter : NSObject

+ (void)routeMenuItem:(RAMenuItem*)menuItem fromController:(BaseViewController*)controller;

@end
