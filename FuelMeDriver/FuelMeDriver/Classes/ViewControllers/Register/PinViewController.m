//
//  PinViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 2/27/15.
//  Copyright (c) 2015 FuelMe LLC. All rights reserved.
//

#import "PinViewController.h"

#import "ErrorReporter.h"
#import "NSString+Utils.h"
#import "RideDriver-Swift.h"
#import "RAAlertManager.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface PinViewController ()

@property (nonatomic) NSString *token;
@property (nonatomic) NSString *mobile;

@end

@implementation PinViewController

#pragma mark - Init

- (id)initWithToken:(NSString *)token mobile:(NSString *)mobile delegate:(id<PhoneVerificationDelegate>)delegate {
    if (self = [super init]) {
        self.token      = token;
        self.mobile     = mobile;
        self.delegate   = delegate;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"Verify Mobile";
    self.titleLabel.text = [NSString stringWithFormat:[@"that was sent to %@" localized], self.mobile];
    
    if (@available(iOS 12.0, *)) {
        self.oneTimePinField.textContentType = UITextContentTypeOneTimeCode;
    }
    [self.oneTimePinField becomeFirstResponder];
    
    //FIX BSIOS-3909
    [self.btnResendText setEnabled:NO];
    [self enableButtonWithDelay];
    
    [self.oneTimePinField addTarget:self
                             action:@selector(textFieldDidChange:)
                   forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - IBActions

- (IBAction)resendText:(id)sender {
    [self showHUD];
     __weak PinViewController *weakSelf = self;
    
    //FIX BSIOS-3909
    [self.btnResendText setEnabled:NO];
    [PhoneVerificationAPI postVerifyPhone:self.mobile completion:^(NSString * _Nullable token, NSError * _Nullable error) {
        //FIX BSIOS-3909
        [weakSelf enableButtonWithDelay];
        __strong PinViewController *strongSelf = weakSelf;
        [strongSelf hideHUD];
        if (token) {
            self.token = token;
        } else {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

- (IBAction)changeMobile:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doCancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers

- (void)enableButtonWithDelay {
    if ([self respondsToSelector:@selector(enableButton)]) {
        [self performSelector:@selector(enableButton) withObject:self afterDelay:10];
    }
}

- (void)enableButton {
    [self.btnResendText setEnabled:YES];
}

- (void)validatePin {
    [self showHUD];
    [self.oneTimePinField setEnabled:NO];

    NSString *pin = self.oneTimePinField.text;
    
    __weak PinViewController *weakSelf = self;
    [PhoneVerificationAPI postVerifyCode:pin token:self.token completion:^(BOOL success, NSError * _Nullable error) {
        __strong PinViewController *strongSelf = weakSelf;
        [self.oneTimePinField setEnabled:YES];
        if (success) {
            
            [self.btnResendText setEnabled:NO];
            [self didVerifyPhone];
        } else {
            // Ask user to re-attempt verification
            [strongSelf resetState];
            [weakSelf hideHUD];
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

- (void)didVerifyPhone {
    [self.delegate phoneVerificationDidSucceed];
}

- (void)resetState {
    self.oneTimePinField.text = @"";
    [self.oneTimePinField becomeFirstResponder];
}


-(void) textFieldDidChange: (UITextField *)textField {
    if ([textField.text length] >= 4) {
        [self validatePin];
    }
}

@end
