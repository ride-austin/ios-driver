//
//  RASimpleAlertView.m
//  Ride
//
//  Created by Roberto Abreu on 14/9/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RASimpleAlertView.h"

#import "KLCPopup.h"

const CGFloat kAlertWidth = 277.0;
const CGFloat kMessageMargin = 14;

@interface RASimpleAlertView()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) KLCPopup *popup;

@end

@implementation RASimpleAlertView

+ (RASimpleAlertView*)simpleAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIFont *fontMessage = [UIFont fontWithName:@"Montserrat-UltraLight" size:13.0];
    
    CGFloat baseMessageHeight = 25.0;
    CGRect messageSize = [message boundingRectWithSize:CGSizeMake(kAlertWidth - kMessageMargin * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:fontMessage} context:nil];
    
    CGFloat baseHeight = 132.0;
    
    RASimpleAlertView *alert = [[RASimpleAlertView alloc] initWithFrame:CGRectMake(0, 0, kAlertWidth, baseHeight + (messageSize.size.height - baseMessageHeight))];
    alert.title.text = title;
    
    alert.lblMessage.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    alert.lblMessage.text = message;
    
    alert.popup = [KLCPopup popupWithContentView:alert.containerView showType:KLCPopupShowTypeGrowIn dismissType:KLCPopupDismissTypeShrinkOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    return alert;
}

- (void)show {
    [self.popup show];
}

- (IBAction)dismiss:(id)sender {
    [self.popup dismiss:YES];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:@"RASimpleAlertView" owner:self options:nil];
        self.containerView.frame = frame;
    }
    return self;
}

@end
