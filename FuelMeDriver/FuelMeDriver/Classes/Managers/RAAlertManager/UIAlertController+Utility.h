//
//  UIAlertController+Utility.h
//  RAAlertManager
//
//  Created by Robert on 13/2/17.
//  Copyright © 2017 Crossover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Utility)

@property (nonatomic, readonly) UIWindow *windowAlert;

- (void)show;
- (void)showOnTop;
- (void)show:(BOOL)animated onTop:(BOOL)onTop;
- (BOOL)isShowing;

@end
