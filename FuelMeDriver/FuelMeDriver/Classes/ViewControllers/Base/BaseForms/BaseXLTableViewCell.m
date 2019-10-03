//
//  BaseXLTableViewCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTableViewCell.h"

@implementation BaseXLTableViewCell
-(void)configure {
    [super configure];
    
    // configure defaults
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.lbErrorMessage.alpha = 0;
}

#pragma mark - Animations
- (void)animate {
    [self shakeCell];
    [self animateColorOfCell];
}
-(void)shakeCell {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values =  @[ @0, @20, @-20, @10, @0];
    animation.keyTimes = @[@0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.additive = YES;
    
    [self.layer addAnimation:animation forKey:@"shake"];
}
-(void)animateColorOfCell {
    __weak __typeof__(self) weakself = self;
    
    UIColor *temp = self.backgroundColor;
    self.backgroundColor = [UIColor redColor];
    [UIView animateWithDuration:0.3 animations:^{
        weakself.backgroundColor = temp;
    }];
}
- (void)validateWithStatus: (XLFormValidationStatus *)status {
    BOOL shouldShowError = status && status.isValid == NO;
    self.lbErrorMessage.text  = shouldShowError ? status.msg : @"";
    self.lbErrorMessage.alpha = shouldShowError;
}
@end
