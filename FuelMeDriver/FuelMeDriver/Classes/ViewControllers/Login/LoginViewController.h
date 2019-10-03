//
//  LoginViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 9/19/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

@class PaddedTextField;

@interface LoginViewController : BaseViewController<UITextFieldDelegate>

@property(nonatomic, strong) IBOutlet PaddedTextField *emailTextField;
@property(nonatomic, strong) IBOutlet PaddedTextField *passwordTextField;

@property (nonatomic, readonly) BOOL fbLoginFailed;

- (IBAction)doFacebook:(id)sender;

- (void)continueLoginFromFBApp;

@end

