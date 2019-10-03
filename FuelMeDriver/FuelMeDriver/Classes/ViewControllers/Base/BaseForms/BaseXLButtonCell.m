//
//  BaseXLButtonCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLButtonCell.h"

NSString * const XLFormRowDescriptorTypeBaseXLButtonCell = @"XLFormRowDescriptorTypeBaseXLButtonCell";

@interface BaseXLButtonCell()

@end
@implementation BaseXLButtonCell
#pragma mark - XLFormLifeCycle
+(void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeBaseXLButtonCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}
-(void)configure {
    [super configure];
}
-(void)update {
    [super update];
    [self.button setTitle:self.rowDescriptor.title forState:UIControlStateNormal];
    [self.button setAccessibilityIdentifier:self.rowDescriptor.title];
    [self.button setAccessibilityLabel:self.rowDescriptor.title];
    self.button.isAccessibilityElement = YES;
}
- (IBAction)didTapButton:(UIButton *)sender {
    [self.formViewController performFormSelector:self.rowDescriptor.action.formSelector withObject:self.rowDescriptor];
}
+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    CGFloat btnHeight = 50;
    CGFloat topMargin = 10;
    CGFloat btmMargin = 20;
    return btnHeight+topMargin+btmMargin;
}
@end
