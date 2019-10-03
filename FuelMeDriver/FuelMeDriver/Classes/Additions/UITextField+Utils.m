//
//  UITextField+Utils.m
//  RideDriver
//
//  Created by Roberto Abreu on 17/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "UITextField+Utils.h"

@implementation UITextField (Utils)

- (void)setLeftPaddingWithSpace:(CGFloat)space {
    UIView *leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space, self.bounds.size.height)];
    leftPadding.backgroundColor = [UIColor clearColor];
    self.leftView = leftPadding;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setRightPaddingWithSpace:(CGFloat)space {
    UIView *rightPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space, self.bounds.size.height)];
    rightPadding.backgroundColor = [UIColor clearColor];
    self.rightView = rightPadding;
    self.rightViewMode = UITextFieldViewModeAlways;
}

@end
