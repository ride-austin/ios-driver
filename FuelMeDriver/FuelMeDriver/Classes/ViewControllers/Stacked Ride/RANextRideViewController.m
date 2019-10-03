//
//  RANextRideViewController.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 12/21/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RANextRideViewController.h"

#import "NSString+Utils.h"
#import "RARideAPI.h"
#import "Util.h"
#import "RAAlertManager.h"

#import "KLCPopup.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RANextRideViewController ()

//IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *lblRiderName;
@property (weak, nonatomic) IBOutlet UILabel *lblCarCategory;
@property (weak, nonatomic) IBOutlet UIImageView *ivRider;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelPickup;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnMessage;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewContainerWidthConstraint;

//Properties
@property (strong, nonatomic) KLCPopup *popup;

@end

@implementation RANextRideViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    [self configureUI];
}

#pragma mark - Configure UI

- (void)configureUI {
    NSString *firstName = self.nextRide.rider.firstName;
    self.lblRiderName.text = firstName;
    self.lblCarCategory.text = self.nextRide.requestedCarType.title.uppercaseString;
    [self.ivRider sd_setImageWithURL:self.nextRide.rider.photoURL placeholderImage:[UIImage imageNamed:@""]];
    
    self.lblPickupAddress.text = self.nextRide.startAddress.fullAddress;
    
    NSDictionary *attributes = @{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
    NSAttributedString *cancelPickupTitle = [[NSAttributedString alloc] initWithString:[@"Cancel Pickup" localized] attributes:attributes];
    [self.btnCancelPickup setAttributedTitle:cancelPickupTitle forState:UIControlStateNormal];
    
    NSString *callTitle = [NSString stringWithFormat:[@"  CALL %@" localized], firstName.uppercaseString];
    [self.btnCall setTitle:callTitle forState:UIControlStateNormal];
    
    NSString *smsTitle = [NSString stringWithFormat:[@"  TEXT %@" localized], firstName.uppercaseString];
    [self.btnMessage setTitle:smsTitle forState:UIControlStateNormal];
}

- (void)configureLayout {
    CGFloat maxContainerWidth = 355;
    CGFloat minContainerWidth = 300;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat sideMargin = 20;
    CGFloat containerWidth = MAX(MIN(screenWidth - sideMargin * 2, maxContainerWidth),minContainerWidth);
    self.viewContainerWidthConstraint.constant = containerWidth;
    [self.view layoutIfNeeded];
}

#pragma mark - IBActions

- (IBAction)didTapCall:(UIButton *)sender {
    [Util startContactCallWithPhoneNumber:[Util maskNumberIfNeeded:self.nextRide.rider.phoneNumber]];
}

- (IBAction)didTapSMS:(UIButton *)sender {
    [Util startContactSMSWithPhoneNumber:[Util maskNumberIfNeeded:self.nextRide.rider.phoneNumber]];
}

- (IBAction)didTapCancelRider:(UIButton *)sender {
    RAAlertOption *options = [RAAlertOption optionWithState:StateActive];
    
    [options addAction:[RAAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil]];
    
    __weak RANextRideViewController *weakSelf = self;
    [options addAction:[RAAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nullable action) {
        [weakSelf showHUD];
        [RARideAPI cancelRide:weakSelf.nextRide.modelID.stringValue withReason:nil andComment:nil andCompletion:^(NSError *error) {
            [weakSelf hideHUD];
            if (error) {
                [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateAll andShownOption:AllowNetworkError]];
            } else {
                [[DriverManager shared] setNextRide:nil];
                [weakSelf dismiss];
            }
        }];
    }]];
    
    [RAAlertManager showAlertWithTitle:[@"Cancel Ride" localized] message:[@"Are you sure you want to cancel this ride?" localized] options:options];
}

- (IBAction)didTapDismiss {
    [self dismiss];
}

#pragma mark - Presentation Methods

- (void)show {
    self.popup = [KLCPopup popupWithContentView:self.view showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    __weak RANextRideViewController *weakSelf = self;
    [self.popup setDidFinishDismissingCompletion:^{
        if (weakSelf.dismissCompletion) {
            weakSelf.dismissCompletion();
        }
    }];
    
    [self.popup show];
}

- (void)dismiss {
    [self.popup dismiss:YES];
}

@end
