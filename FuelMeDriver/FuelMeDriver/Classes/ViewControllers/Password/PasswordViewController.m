//
//  PasswordViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 11/11/12.
//  Copyright (c) 2012 FuelMe. All rights reserved.
//

#import "PasswordViewController.h"

#import "NSString+Utils.h"
#import "PaddedTextField.h"
#import "RAAlertManager.h"

@implementation PasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = [@"Change Password" localized];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[@"SAVE" localized] style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    doneButton.tintColor = [UIColor colorWithRed:2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1.0];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [self addEdgeInsetsToTextFields];
    
    [self.password becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

#pragma mark - Validations

- (NSString*)validateFields {
    NSString* value = nil;
    
    //RA-1133: Implemeted validation category
    if (![self.password isValidPassword]) {
        value = [NSString stringWithFormat:[@"Please choose a password with at least %ld or more characters." localized], (long)kMinPasswordLength];
    } else {
        if (![self.password isValidConfirmationPassword:self.confirmPassword]) {
            value = NSLocalizedString(@"Passwords do not match", @"");
        }
    }
    
    return value;
}

- (BOOL)validate {
    BOOL valid = NO;
    [self.view endEditing:YES];
    NSString* message = [self validateFields];
    if (!message) {
        valid = YES;
    } else {
        //RA-1133: to avoid prevent displaying the error alert
        [RAAlertManager showErrorWithAlertItem:message andOptions:[RAAlertOption optionWithState:StateActive andShownOption:Overlap]];
        [self.password becomeFirstResponder];
    }
    
    return valid;
}

- (void)save {
    //validate before continue
    if (![self validate]) {
        return;
    }
    
    [self showHUD];
    [[RASessionManager shared] updatePassword:self.password.text withCompletion:^(NSError *error) {
                                    [self hideHUD];
                                    if (!error) {
                                        [RAAlertManager showAlertWithTitle:@"" message:[@"Password changed successfully" localized] options:[RAAlertOption optionWithState:StateActive]];
                                        
                                        if (self.navigationController.viewControllers.count > 1) {
                                            [self.navigationController popViewControllerAnimated:YES];
                                        }
                                    } else {
                                        [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                                    }
                                }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.password){
        [self.confirmPassword becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self save];
    }
    return YES;
}

- (void)addEdgeInsetsToTextFields {
    CGRect rect = CGRectMake(0, 0, 15, 40);
    
    self.password.leftView = [[UIView alloc] initWithFrame:rect];
    self.password.leftViewMode = UITextFieldViewModeAlways;
    
    self.confirmPassword.leftView = [[UIView alloc] initWithFrame:rect];
    self.confirmPassword.leftViewMode = UITextFieldViewModeAlways;
}

@end
