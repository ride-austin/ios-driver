//
//  RAUpgradePopup.m
//  RideDriver
//
//  Created by Roberto Abreu on 6/14/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAUpgradePopup.h"

#import "KLCPopup.h"

@interface RAUpgradePopup ()

//IBOutlets
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *iconState;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBodyContent;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

//Properties
@property (strong, nonatomic) KLCPopup *popup;
@property (strong, nonatomic) NSString *targetName;
@property (nonatomic, assign) UpgradeStatus status;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightCancelUpgradeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopCloseBtn;

@end

@implementation RAUpgradePopup

+ (instancetype)upgradePopupWithTargetName:(NSString *)targetName status:(UpgradeStatus)status andDelegate:(id<RAUpgradePopupDelegate>)delegate {
    RAUpgradePopup *upgradePopup = [[RAUpgradePopup alloc] initWithFrame:CGRectMake(0, 0 , 280, 426)];
    upgradePopup.targetName = targetName;
    upgradePopup.delegate = delegate;
    [upgradePopup updateToStatus:status];
    return upgradePopup;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView {
    [[NSBundle mainBundle] loadNibNamed:@"RAUpgradePopup" owner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    [self setupUI];
}

- (void)setupUI {
    NSDictionary *attributes = @{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
                                  NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:20.0]
                                  };
    NSAttributedString *disableRoundUpTitle = [[NSAttributedString alloc] initWithString:@"Cancel Upgrade" attributes:attributes];
    [self.btnCancel setAttributedTitle:disableRoundUpTitle forState:UIControlStateNormal];
}

- (void)updateToStatus:(UpgradeStatus)upgradeState {
    self.status = upgradeState;
    switch (upgradeState) {
        case UpgradeRequested:
            self.iconState.image = [UIImage imageNamed:@"requestedUpgradeIcon"];
            self.iconState.accessibilityValue = @"iconRequested";
            self.lblTitle.text = [NSString stringWithFormat:@"Upgrade to %@",self.targetName];
            self.lblBodyContent.text = @"Waiting for Rider's Cofirmation";
            self.constraintHeightCancelUpgradeBtn.constant = 54.0;
            self.constraintTopCloseBtn.constant = 41.0;
            break;
        case UpgradeAccepted:
            self.iconState.image = [UIImage imageNamed:@"acceptedUpgradeIcon"];
            self.iconState.accessibilityValue = @"iconAccepted";
            self.lblTitle.text = @"Rider confirmed";
            self.lblBodyContent.text = [NSString stringWithFormat:@"Upgraded to %@",self.targetName];
            self.constraintHeightCancelUpgradeBtn.constant = 0;
            self.constraintTopCloseBtn.constant = 28.0;
            break;
        case UpgradeDeclined:
            self.iconState.image = [UIImage imageNamed:@"declineUpgradeIcon"];
            self.iconState.accessibilityValue = @"iconDeclined";
            self.lblTitle.text = @"Rider denied";
            self.lblBodyContent.text = [NSString stringWithFormat:@"Not Upgrading to %@",self.targetName];
            self.constraintHeightCancelUpgradeBtn.constant = 0;
            self.constraintTopCloseBtn.constant = 28.0;
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView layoutIfNeeded];
    }];
}

#pragma mark - Actions 

- (IBAction)cancelUpgrade:(id)sender {
    if (self.delegate) {
        [self.delegate didTapCancel:self];
    }
}

- (IBAction)close:(id)sender {
    [self dismiss];
}

#pragma mark - Display Methods

- (void)show {
    self.popup = [KLCPopup popupWithContentView:self.contentView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    self.popup.dimmedMaskAlpha = 0.8;
    [self.popup show];
}

- (void)dismiss {
    __weak RAUpgradePopup *weakSelf = self;
    self.popup.didFinishDismissingCompletion = ^{
        if (weakSelf.delegate) {
            [weakSelf.delegate didTapClose:weakSelf];
        }
    };
    [self.popup dismiss:YES];
}

@end
