//
//  BaseXLDatePickerCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLDatePickerCell.h"

#import "DatePickerModel.h"

NSString * const XLFormRowDescriptorTypeBaseXLDatePickerCell = @"XLFormRowDescriptorTypeBaseXLDatePickerCell";

@interface BaseXLDatePickerCell ()
@property (nonatomic) UIDatePicker *datePicker;
@end
@implementation BaseXLDatePickerCell

#pragma mark - XLFormLifeCycle
+(void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeBaseXLDatePickerCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}
-(void)configure {
    [super configure];
}

-(void)update {
    [super update];
    self.lbTitle.text = self.rowDescriptor.title;
    [self didUpdateRowDescriptorValue];
}
-(void)didUpdateRowDescriptorValue {
    if ([self.rowDescriptor.value isKindOfClass:[NSDate class]]) {
        self.lbValue.text = [self.datePickerModel.dateFormatter stringFromDate:self.rowDescriptor.value];
        self.lbPlaceholder.text = @"";
    } else {
        self.lbValue.text = @"";
        self.lbPlaceholder.text = self.rowDescriptor.noValueDisplayText;
    }
}
#pragma mark - XLFormRowDescriptor
-(UIView *)inputView {
    return self.datePicker;
}
-(BOOL)canBecomeFirstResponder {
    return [self.rowDescriptor isDisabled] == NO;
}
-(BOOL)formDescriptorCellCanBecomeFirstResponder {
    return [self.rowDescriptor isDisabled] == NO;
}
-(BOOL)formDescriptorCellBecomeFirstResponder {
    if (self.isFirstResponder) {
        return self.resignFirstResponder;
    }
    return self.becomeFirstResponder;
}
+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 60;
}
#pragma mark - Date Picker
-(UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [UIDatePicker new];
        [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self updateDatePickerWithModel];
    }
    return _datePicker;
}
-(void)datePickerValueChanged:(UIDatePicker *)datePicker {
    self.rowDescriptor.value = datePicker.date;
    [self didUpdateRowDescriptorValue];
}
-(void)updateDatePickerWithModel {
    [self initializeRowDescriptorValueIfNeeded];
    _datePicker.date = self.rowDescriptor.value;
    _datePicker.datePickerMode = self.datePickerModel.datePickerMode;
    _datePicker.minimumDate = self.datePickerModel.minimumDate;
    _datePicker.maximumDate = self.datePickerModel.maximumDate;
    _datePicker.minuteInterval = self.datePickerModel.datePickerMinuteInterval.integerValue ?: 1;
}
-(void)initializeRowDescriptorValueIfNeeded {
    if ([self.rowDescriptor.value isKindOfClass:[NSDate class]] == NO) {
        self.rowDescriptor.value = self.datePickerModel.defaultDate;
        [self didUpdateRowDescriptorValue];
    }
}
@end
