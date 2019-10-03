//
//  UIAlertController+Utility.m
//  RAAlertManager
//
//  Created by Robert on 13/2/17.
//  Copyright © 2017 Crossover. All rights reserved.
//

#import "UIAlertController+Utility.h"
#import <objc/runtime.h>

@interface UIAlertController (Private)

@property (nonatomic, strong) UIWindow *alertWindow;

@end

@implementation UIAlertController (Private)

@dynamic alertWindow;

- (void)setAlertWindow:(UIWindow *)alertWindow {
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow {
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

@end

@implementation UIAlertController (Utility)

- (void)show {
    [self show:YES onTop:NO];
}

- (void)showOnTop {
    [self show:YES onTop:YES];
}

- (void)show:(BOOL)animated onTop:(BOOL)onTop{
    if (self.presentingViewController != nil) {
        __weak __typeof__(self) weakself = self;
        [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
            [weakself safelyShow:animated onTop:onTop];
        }];
    } else {
        [self safelyShow:animated onTop:onTop];
    }
}
- (void)safelyShow:(BOOL)animated onTop:(BOOL)onTop {
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    self.alertWindow.rootViewController = [[UIViewController alloc] init];
    
    if (onTop) {
        UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
        self.alertWindow.windowLevel = topWindow.windowLevel + 1;
    } else {
        self.alertWindow.windowLevel = UIWindowLevelAlert + 1;
    }
    
    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // precaution to insure window gets destroyed
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}

- (BOOL)isShowing {
    return self.alertWindow != nil;
}

- (UIWindow *)windowAlert {
    return [self alertWindow];
}

@end
