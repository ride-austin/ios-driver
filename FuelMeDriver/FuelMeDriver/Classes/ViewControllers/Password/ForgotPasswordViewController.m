//
//  ForgotPasswordViewController.m
//  Ride
//
//  Created by Tyson Bunch on 5/19/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ForgotPasswordViewController.h"

#import "NSString+Utils.h"
#import "PaddedTextField.h"
#import "UITextField+Valid.h"
#import "URLFactory.h"
#import "RAAlertManager.h"

@interface ForgotPasswordViewController ()

@property(nonatomic, strong) UIBarButtonItem* backButton;

@end

@implementation ForgotPasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [super configureAllTapsWillDismissKeyboard];
    self.backButton = self.navigationItem.backBarButtonItem;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = [@"Forgot Password" localized];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 40)];
    self.emailTextField.leftView = paddingView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

#pragma mark - IBActions

- (IBAction)doForgotPassword:(id)sender {
    NSArray *errors = [self validate];
    if (!errors || self.emailTextField!=[errors lastObject]) {
        [self.view endEditing:YES];
        self.backButton.enabled = NO;
        [self showHUD];
        
        NSDictionary *params = @{@"email" : self.emailTextField.text};
        
        __weak ForgotPasswordViewController *weakSelf = self;
        [[NetworkManager sharedInstance] postPath:kPathForgot
                                           params:params
                                    completeBlock:^(NSString *resourceId,  NSInteger statusCode, NSError *error) {
                                        //FIX RA-3861: Avoid use hideHUDForError which includes a delay that crashes delegate
                                        if (error) {
                                            [weakSelf hideHUD];
                                            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
                                        }else{
                                            //RA-4359 show success alert and pop back
                                            [weakSelf showSuccessHUDandPOP];
                                            
                                        }
                                        weakSelf.backButton.enabled = YES;
                                    }];
    } else {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:[@"Sorry" localized] message:[errors objectAtIndex:0] delegate:nil cancelButtonTitle:[@"Ok" localized] otherButtonTitles:nil];
        [av show];;
    }
}

#pragma mark - Validations

- (NSArray*)validate {
    if([self.emailTextField isEmpty]) {
        return @[[@"Please enter your email address." localized], self.emailTextField];
    } else {
        //RA-1133: Implemeted validation category
        if (![self.emailTextField isValidEmail]) {
            return @[[@"Please enter a valid email address." localized], self.emailTextField ];
        }        
    }
    return nil;
}

@end
