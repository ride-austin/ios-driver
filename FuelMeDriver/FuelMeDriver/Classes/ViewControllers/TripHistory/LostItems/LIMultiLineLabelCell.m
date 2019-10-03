//
//  LIMultiLineLabelCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "LIMultiLineLabelCell.h"

NSString * const XLFormRowDescriptorTypeLIMultiLineLabelCell = @"XLFormRowDescriptorTypeLIMultiLineLabelCell";

@interface LIMultiLineLabelCell ()

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbSubtitle;

@end

@implementation LIMultiLineLabelCell

#pragma mark - XLFormLifeCycle

+ (void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeLIMultiLineLabelCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}

- (void)configure {
    [super configure];
    //need to set the font here because nib is failing to set it before cellHeight is called
    self.lbTitle.font = [UIFont fontWithName:@"Montserrat-Regular" size:17.0];
    self.lbSubtitle.font = [UIFont fontWithName:@"Montserrat-Light" size:15.0];
}

- (void)update {
    [super update];
    self.lbTitle.text = self.rowDescriptor.title;
    self.lbSubtitle.text = self.rowDescriptor.value;
    self.rowDescriptor.height = self.cellHeight;
}

- (CGFloat)cellHeight {
    CGFloat maxLabelWidth = [UIScreen mainScreen].bounds.size.width  - CGRectGetMinX(self.lbTitle.frame)*2;
    CGSize maxSize = CGSizeMake(maxLabelWidth, CGFLOAT_MAX);
    CGSize titleSize = [self.lbTitle sizeThatFits:maxSize];
    CGSize subtitleSize = [self.lbSubtitle sizeThatFits:maxSize];
    CGFloat titleToSubtitleDistance = 8;
    CGFloat topMargin = CGRectGetMinY(self.lbTitle.frame);
    CGFloat bottomMargin = 15;
    CGFloat height = topMargin + titleSize.height + titleToSubtitleDistance + subtitleSize.height + bottomMargin;
    return MAX(44,height);
}

@end
