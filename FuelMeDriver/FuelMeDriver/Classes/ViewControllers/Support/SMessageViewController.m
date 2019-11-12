//
//  SMessageViewController.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/2/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "SMessageViewController.h"

#import "SupportTopicAPI.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"
#import "UITextView+Placeholder.h"

#define kBaseMargin 10.0

@interface SMessageViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btSend;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewBottom;

@end

@implementation SMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTextView];
    [self configureNavBar];
    [self addObservers];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)configureTextView {
    self.textView.text = @"";
    self.textView.placeholder = [@"Please enter your message" localized];
}

- (void)configureNavBar {
    self.title = [[NSString stringWithFormat:[@"CONTACT %@" localized],self.recipientName] capitalizedString];
    [self.btSend setTintColor:[UIColor blackColor]];
    [self.btSend setEnabled:NO];
    [self.navigationItem setRightBarButtonItem:self.btSend];
}

- (NSString *)recipientName {
    if ([_recipientName isKindOfClass:[NSString class]]) {
        return _recipientName;
    } else {
        return [@"Support" localizedUppercaseString];
    }
}

#pragma mark - KeyboardObservers

- (void)keyboardDidShow:(NSNotification*)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.constraintTextViewBottom.constant = keyboardSize.height + kBaseMargin;
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide {
    self.constraintTextViewBottom.constant = kBaseMargin;
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self.btSend setEnabled:self.isValidMessage];
}

#pragma mark Validation

- (BOOL)isValidMessage {
    if (self.textView.text && [self.textView.text isKindOfClass:[NSString class]]) {
        NSString *newString = [self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        return ![newString isEqualToString:@""];
    } else {
        return NO;
    }
}

#pragma mark - IBActions

- (IBAction)btSendTapped:(UIBarButtonItem *)sender {
    [self showHUD];
    [SupportTopicAPI postSupportMessage:self.textView.text rideID:self.rideID withCompletion:^(id response, NSError *error) {
        if (error) {
            [self hideHUD];
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
        } else {
            [self showSuccessHUDandPOP];
        }
    }];;
}

@end
