//
//  UIStoryboard+tripHistoryInvoker.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (tripHistoryInvoker)

+ (UIViewController *)tripHistoryViewControllerWithId:(NSString *)identifier;

@end
