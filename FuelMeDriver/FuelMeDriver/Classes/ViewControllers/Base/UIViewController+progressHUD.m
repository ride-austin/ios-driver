//
//  UIViewController+progressHUD.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/26/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "UIViewController+progressHUD.h"

#import <SVProgressHUD/SVProgressHUD.h>

@implementation UIViewController (progressHUD)

- (void)showHUD {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE WAIT...", "")];
}

- (void)hideHUD {
    [SVProgressHUD dismiss];
}

- (void)hideHUDForError:(NSError*)error {
    return [self hideHUD:(error==nil)];
}

- (void)hideHUD:(BOOL)isSuccess {
    [self hideHUD];
    
    if (isSuccess) {
        [SVProgressHUD setSuccessImage:[UIImage imageNamed:@"iconCheckmark"]];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        
        //show SVProgressHUD singleton
        [SVProgressHUD showSuccessWithStatus:@""];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismissWithDelay:1.0];
        });
    }
}

- (void)showSuccessHUDWithCompletion:(void(^)(void))completion {
    CGFloat duration = 1.5;
    [SVProgressHUD setFont:[UIFont fontWithName:@"Montserrat-Light" size:13]];
    [SVProgressHUD setSuccessImage:[UIImage imageNamed:@"iconCheckmark"]];
    [SVProgressHUD setCornerRadius:6];
    [SVProgressHUD setMinimumDismissTimeInterval:duration];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    //show SVProgressHUD with Success
    [SVProgressHUD showSuccessWithStatus:@"SUCCESS"]; //--> This One Dismiss After Time Interval
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
    });
}

- (void)showSuccessHUDandPOP {
    __weak __typeof__(self) weakself = self;
    [self showSuccessHUDWithCompletion:^{
        if ([weakself.navigationController.topViewController isKindOfClass:[self class]]) {
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
