//
//  CFReasonTableViewCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/26/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "CFReasonTableViewCell.h"
NSString * const XLFormRowDescriptorTypeCFReasonTableViewCell = @"XLFormRowDescriptorTypeCFReasonTableViewCell";

@interface CFReasonTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *ivCheck;
@property (weak, nonatomic) IBOutlet UIView *vCircle;
@property (nonatomic, copy) void(^willSelectBlock)(NSString *rowTag);
@end


@implementation CFReasonTableViewCell

#pragma mark - XLFormLifeCycle
+ (void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeCFReasonTableViewCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}

- (void)configure {
    [super configure];
    [self configureCircle];
}

- (void)update {
    [super update];
    self.lbTitle.text = self.rowDescriptor.title;
    [self updateSelected:[self.rowDescriptor.value boolValue]];
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    self.willSelectBlock(self.rowDescriptor.tag);
    self.rowDescriptor.value = [NSNumber numberWithBool:![self.rowDescriptor.value boolValue]];
    [self.formViewController updateFormRow:self.rowDescriptor];
    [controller.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
}

#pragma mark - Helpers
- (void)configureCircle {
    self.vCircle.layer.borderColor = [UIColor whiteColor].CGColor;
    self.vCircle.layer.borderWidth = 1.0;
    self.vCircle.layer.cornerRadius = self.vCircle.frame.size.height/2.0;
    self.vCircle.userInteractionEnabled = NO;
}

- (void)updateSelected:(BOOL)selected {
    self.ivCheck.hidden = !selected;
    self.vCircle.hidden = selected;
}

@end
