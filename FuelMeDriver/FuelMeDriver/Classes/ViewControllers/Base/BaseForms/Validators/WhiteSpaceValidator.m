//
//  WhiteSpaceValidator.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "WhiteSpaceValidator.h"

@interface WhiteSpaceValidator()
@property (nonatomic, readonly) NSString *msg;
@end
@implementation WhiteSpaceValidator
-(instancetype)initWithMessage:(NSString *)message {
    if (self = [super init]) {
        _msg = message;
    }
    return self;
}

+(XLFormValidator *)validatorWithMessage:(NSString *)message {
    return [[self alloc] initWithMessage:message];
}
-(XLFormValidationStatus *)isValid:(XLFormRowDescriptor *)row {
    NSString *errorMsg = self.msg ?: [NSString stringWithFormat:@"%@ can't be empty", row.title?:row.tag];
    if (row.value != nil) {
        id value = row.value;
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [value stringValue];
        }
        
        if ([value isKindOfClass:[NSString class]]) {
             BOOL isValidString = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
            return [XLFormValidationStatus formValidationStatusWithMsg:errorMsg status:isValidString rowDescriptor:row];
        }
    }
    return [XLFormValidationStatus formValidationStatusWithMsg:errorMsg status:NO rowDescriptor:row];
}
@end
