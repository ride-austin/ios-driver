//
//  BaseXLBooleanPickerCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLBooleanPickerCell.h"

NSString * const XLFormRowDescriptorTypeBaseXLBooleanPickerCell = @"XLFormRowDescriptorTypeBaseXLBooleanPickerCell";

@implementation BaseXLBooleanPickerCell
+(void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeBaseXLBooleanPickerCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}
-(void)configure {
    [super configure];
}

-(void)update {
    [super update];
}
+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 60;
}
@end
