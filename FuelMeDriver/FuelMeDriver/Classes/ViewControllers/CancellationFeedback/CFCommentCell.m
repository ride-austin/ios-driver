//
//  CFCommentCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/27/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "CFCommentCell.h"

NSString * const XLFormRowDescriptorTypeCFCommentCell = @"XLFormRowDescriptorTypeCFCommentCell";

@implementation CFCommentCell

+ (void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeCFCommentCell : NSStringFromClass(self.class)};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textView.layer.borderWidth = 1;
    self.placeholderView.layer.borderWidth = 1;
    self.textView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.placeholderView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.textView.layer.cornerRadius = 4;
}

@end
