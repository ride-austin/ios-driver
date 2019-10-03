//
//  SupportViewController.m
//  Ride
//
//  Created by Robert on 7/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "SupportViewController.h"

#import "CALayer+UIColor.h"
#import "SupportTopicAPI.h"
#import "UIColor+HexUtils.h"
#import "NSString+Utils.h"
#import "RAAlertManager.h"

#import "KLCPopup.h"

#define kPlaceHolderColor [UIColor colorWithRed:145/255.0 green:148/255.0 blue:153/255.0 alpha:1.0];
#define kTextColor [UIColor colorWithRed:60/255.0 green:67/255.0 blue:80/255.0 alpha:1.0];
#define kPlaceHolderText @"Share Details"
#define kTextViewHeight 170

@interface SupportViewController () <UITextViewDelegate>

//Outlets
@property (weak, nonatomic) IBOutlet UITextView *tvIssueDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewHeight;
@property (strong, nonatomic) IBOutlet UIView *successView;

//Flags
@property (assign, nonatomic) BOOL validDetails;

@end

@implementation SupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.validDetails = NO;
    [self addObservers];
    [self setupUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    self.tvIssueDetails.text = [kPlaceHolderText localized];
    self.tvIssueDetails.textColor = kPlaceHolderColor;
    self.tvIssueDetails.textContainerInset = UIEdgeInsetsMake(11.0, 14.0, 11.0, 14.0);
    [self setSubmitButtonEnable:NO];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setSubmitButtonEnable:(BOOL)enabled {
    self.btnSubmit.enabled = enabled;
    self.btnSubmit.backgroundColor = enabled ? [UIColor colorWithHex:@"#02A7F9"] : [UIColor colorWithHex:@"#D8D8D8"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.tvIssueDetails resignFirstResponder];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    CGFloat baseFrameY = self.view.frame.size.height;
    CGFloat keyboardY = baseFrameY - CGRectGetHeight(keyboardFrame);
    
    if (keyboardY <= CGRectGetMaxY(self.btnSubmit.frame)) {
        CGFloat btnY = CGRectGetMaxY(self.btnSubmit.frame);
        CGFloat offsetY = btnY - keyboardY;
        const CGFloat margin = 15;
        CGFloat value = kTextViewHeight - offsetY - margin;
        [self updateTextViewConstraint:value];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self updateTextViewConstraint:kTextViewHeight];
}

- (void)updateTextViewConstraint:(CGFloat)value {
    self.constraintTextViewHeight.constant = value;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.tvIssueDetails.text isEqualToString:[kPlaceHolderText localized]] && !self.validDetails) {
        self.tvIssueDetails.text = @"";
        self.tvIssueDetails.textColor = kTextColor;
        return;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.tvIssueDetails.text isEqualToString:@""]) {
        self.tvIssueDetails.text = [kPlaceHolderText localized];
        self.tvIssueDetails.textColor = kPlaceHolderColor;
        self.validDetails = NO;
        return;
    }
    
    self.validDetails = YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    BOOL validText = ![textView.text isEqualToString:@""];
    [self setSubmitButtonEnable:validText];
}

#pragma mark - Submit Action

- (IBAction)submitPressed:(id)sender {
    [self.tvIssueDetails resignFirstResponder];
    [self showHUD];
    NSString *supportMessage = self.tvIssueDetails.text;
    [SupportTopicAPI postSupportMessage:supportMessage supportTopic:self.selectedSupportTopic rideId:self.rideId withCompletion:^(NSError *error) {
        [self hideHUD];
        if (!error) {
            [self showCustomSuccessAndPop];
        } else {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        }
    }];
}

- (void)showCustomSuccessAndPop {
    KLCPopup *successPopup = [KLCPopup popupWithContentView:self.successView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [successPopup show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [successPopup dismiss:YES];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
