//
//  LIFieldViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "LIFieldViewModel.h"

#import "DatePickerModel.h"
#import "LIFieldDataModel.h"
#import "LIOptionDataModel.h"
#import "TextFieldModel.h"

@interface LIFieldViewModel()

@property (nonatomic) NSString *fieldType;

@end

@implementation LIFieldViewModel

+ (instancetype)viewModelWithDataModel:(LIFieldDataModel *)model {
    return [[self alloc] initWithDataModel:model];
}

- (instancetype)initWithDataModel:(LIFieldDataModel *)model {
    if (self = [super init]) {
        _title       = model.fieldTitle;
        _variable    = model.variable;
        _placeholder = model.fieldPlaceholder;
        _fieldType   = model.fieldType;
        if (model.isMandatory) {
            _requireMsg = [NSString stringWithFormat:@"Please input %@", _title];
        }
    }
    return self;
}

- (NSString *)rowType {
    if ([self.fieldType isEqualToString:@"phone"]) {
        return XLFormRowDescriptorTypeBaseXLPhonePickerCell;
    } else if ([self.fieldType isEqualToString:@"text"]) {
        return XLFormRowDescriptorTypeBaseXLTextViewCell;
    } else if ([self.fieldType isEqualToString:@"bool"]) {
        return XLFormRowDescriptorTypeBaseXLBooleanPickerCell;
    } else if ([self.fieldType isEqualToString:@"date"]) {
        return XLFormRowDescriptorTypeBaseXLDatePickerCell;
    } else if ([self.fieldType isEqualToString:@"photo"]) {
        return XLFormRowDescriptorTypeBaseXLImagePickerCell;
    } else {
        return XLFormRowDescriptorTypeBaseXLTextViewCell;
    }
}

- (id)model {
    if ([self.fieldType isEqualToString:@"phone"]) {
        return [TextFieldModel phone];
    } else if ([self.fieldType isEqualToString:@"text"]) {
        return [TextFieldModel details];
    } else if ([self.fieldType isEqualToString:@"bool"]) {
        return [TextFieldModel details];
    } else if ([self.fieldType isEqualToString:@"date"]) {
        NSTimeInterval secondsInAYear = 60*60*24*365;
        NSDate *oneYearInThePast = [NSDate dateWithTimeIntervalSinceNow:-secondsInAYear];
        DatePickerModel *model = [DatePickerModel datePickerMode:UIDatePickerModeDateAndTime fromPastDate:oneYearInThePast];
        model.datePickerMinuteInterval = @(15);
        model.dateFormatter = [NSDateFormatter new];
        model.dateFormatter.dateFormat = @"MMM dd yyyy 'at' hh:mm a";
        return model;
    } else if ([self.fieldType isEqualToString:@"photo"]) {
        return nil;
    } else {
        return [TextFieldModel details];
    }
}

@end
