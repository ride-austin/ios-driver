//
//  XLFormRowDescriptor+factory.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "XLFormRowDescriptor+factory.h"

#import "DatePickerModel.h"
#import "TextFieldModel.h"
#import "WhiteSpaceValidator.h"

@implementation XLFormRowDescriptor (factory)
+(instancetype)rowTextFieldWithTag:(NSString *)rowTag
                             title:(NSString *)title
                             value:(id)value
                       placeholder:(id)placeholder
                           rowType:(NSString *)rowType
                             model:(TextFieldModel *)textFieldModel
                    requireMessage:(NSString *)requireMsg
                 andValidatorArray:(NSArray<id<XLFormValidatorProtocol>> *)arrayValidator {
    
    XLFormRowDescriptor *row = [self formRowDescriptorWithTag:rowTag rowType:rowType];
    row.title = title;
    row.value = value;
    [row updateWithRequireMessage:requireMsg];
    if (row.required) {
        [row addValidator:[WhiteSpaceValidator validatorWithMessage:row.requireMsg]];
    }
    [row updateWithPlaceholder:placeholder];
    
    //
    //  MODEL
    //
    if ([textFieldModel isKindOfClass:[textFieldModel class]] == NO) {
        textFieldModel = [TextFieldModel new];
    }
    row.cellConfigAtConfigure[@"textFieldModel"] = textFieldModel;
    
    //
    //  VALIDATOR
    //
    if ([arrayValidator isKindOfClass:[NSArray class]]) {
        for (id<XLFormValidatorProtocol> validator in arrayValidator) {
            [row addValidator:validator];
        }
    }
    return row;
}
+(instancetype)rowButtonWithTitleAndTag:(NSString *)rowTag
                                rowType:(NSString *)rowType
                               selector:(SEL)selector {

    XLFormRowDescriptor *row = [self formRowDescriptorWithTag:rowTag rowType:rowType];
    row.title = rowTag;
    row.action.formSelector = selector;
    return row;
}
+(instancetype)rowImagePickerWithTag:(NSString *)rowTag
                               title:(NSString *)title
                             rowType:(NSString *)rowType
                      requireMessage:(NSString *)requireMsg {
    
    XLFormRowDescriptor *row = [self formRowDescriptorWithTag:rowTag rowType:rowType];
    row.title = title;
    [row updateWithRequireMessage:requireMsg];
    return row;
}
+(instancetype)rowDatePickerWithTag:(NSString *)rowTag
                              title:(NSString *)title
                              value:(id)value
                        placeholder:(id)placeholder
                            rowType:(NSString *)rowType
                              model:(DatePickerModel *)datePickerModel
                     requireMessage:(NSString *)requireMsg {
    
    XLFormRowDescriptor *row = [self formRowDescriptorWithTag:rowTag rowType:rowType];
    row.title = title;
    row.value = value;
    [row updateWithRequireMessage:requireMsg];
    [row updateWithPlaceholder:placeholder];
    
    //
    //  MODEL
    //
    if ([datePickerModel isKindOfClass:DatePickerModel.class] == NO) {
        datePickerModel = [DatePickerModel datePickerMode:UIDatePickerModeDate fromPastDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*365]];
    }
    row.cellConfigAtConfigure[@"datePickerModel"] = datePickerModel;
    return row;
}
+(instancetype)rowBooleanPickerWithTag:(NSString *)rowTag
                                 title:(NSString *)title
                                 value:(id)value
                           placeholder:(id)placeholder
                               rowType:(NSString *)rowType
                        requireMessage:(NSString *)requireMsg {
    
    XLFormRowDescriptor *row = [self formRowDescriptorWithTag:rowTag rowType:rowType];
    row.title = title;
    row.value = value;
    row.selectorOptions =
    @[[XLFormOptionsObject formOptionsObjectWithValue:@YES displayText:@"Yes"],
      [XLFormOptionsObject formOptionsObjectWithValue:@NO  displayText:@"No"]];
    [row updateWithRequireMessage:requireMsg];
    return row;
}
#pragma mark - Helpers
-(void)updateWithRequireMessage:(NSString *)requireMsg {
    //
    //  REQUIRED
    //
    if (requireMsg
        && [requireMsg isKindOfClass:[NSString class]]
        && [requireMsg isEqualToString:@""] == NO) {
        self.required   = YES;
        self.requireMsg = requireMsg;
    }
}
-(void)updateWithPlaceholder:(NSString *)placeholder {
    //
    //  PLACEHOLDER
    //
    if ([placeholder isKindOfClass:[NSString class]]) {
        self.noValueDisplayText = placeholder;
    }
}
@end
