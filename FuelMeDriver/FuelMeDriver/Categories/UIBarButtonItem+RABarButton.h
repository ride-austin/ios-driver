//
//  UIBarButtonItem+RABarButton.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 3/9/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (RABarButton)
+ (UIBarButtonItem *)RABarButtonWithTitle:(NSString *)title
                                   target:(id)target
                                   action:(SEL)action;
@end
