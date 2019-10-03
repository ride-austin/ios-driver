//
//  UIViewController+progressHUD.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/26/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (progressHUD)

- (void)showHUD;
- (void)hideHUDForError:( NSError* _Nullable )error;
- (void)hideHUD:(BOOL)isSuccess;
- (void)hideHUD;

- (void)showSuccessHUDWithCompletion:(void(^ _Nullable)(void))completion;
- (void)showSuccessHUDandPOP;

@end
