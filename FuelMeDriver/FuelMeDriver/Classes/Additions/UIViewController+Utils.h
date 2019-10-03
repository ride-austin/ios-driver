//
//  UIViewController+Utils.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/23/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Utils)

@property (nonatomic,assign) BOOL isShowing;

- (BOOL)isVisible;
- (void)setupNavigationTitleWithString:(NSString*)title;
- (void)setupNavigationTitleWithTitle:(NSString*)title andSubtitle:(NSString*)subtitle;

@end
