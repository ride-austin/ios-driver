//
//  RASimpleAlertView.h
//  Ride
//
//  Created by Roberto Abreu on 14/9/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTTAttributedLabel.h"

@interface RASimpleAlertView : UIView

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *lblMessage;

+ (RASimpleAlertView*)simpleAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message;
- (void)show;

@end
