//
//  UIStoryboard+UniqueViewControllerFactory.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/14/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (UniqueViewControllerFactory)
+(UIViewController *)viewControllerForID:(NSString *)uniqueStoryboardID;
@end
