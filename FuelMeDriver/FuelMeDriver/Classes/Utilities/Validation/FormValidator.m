//
//  FormValidator.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/2/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "FormValidator.h"

@interface FormValidator ()

@property (nonatomic) TFType type;
@property (nonatomic) NSUInteger maxLength;
@property (nonatomic) NSString *validCharacters;
@property (nonatomic) NSNumber *maxNumericalValue;

@end

@implementation FormValidator

+ (instancetype)validatorWithType:(TFType)type {
    FormValidator *validator = [[FormValidator alloc] initWithType:TFTypeLicensePlate];
    return validator;
}

+ (instancetype)tipValidatorWithMax:(NSNumber *)maxTip {
    FormValidator *validator = [[FormValidator alloc] initWithType:TFTypeTip];
    validator.maxNumericalValue = maxTip;
    return validator;
}

- (instancetype)initWithType:(TFType)type {
    self = [super init];
    if (self) {
        switch (type) {
            case TFTypeLicensePlate:
                _maxLength = 9;
                _validCharacters = @"1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                break;
            case TFTypeTip:
                _maxLength = 3;
                _validCharacters = @"1234567890";
                break;
        }
    }
    return self;
}

- (void)setType:(TFType)type {
    _type = type;
}

- (BOOL)isValid:(NSString *)text {
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([text isKindOfClass:[NSString class]] && text.length > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self validatedString:string.uppercaseString]) {
        NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string.uppercaseString];
        BOOL isMax = updatedString.length >= self.maxLength;
        NSString *limitedString = isMax ? [updatedString substringToIndex:self.maxLength] : updatedString;
        textField.text = limitedString;
        if (isMax) {
            if (self.maxNumericalValue != nil) {
                if (limitedString.doubleValue > self.maxNumericalValue.doubleValue) {
                    textField.text = self.maxNumericalValue.stringValue;
                } else {
                    [textField endEditing:YES];
                }
            } else {
                [textField endEditing:YES];
            }
        }
        return NO;
    } else {
        return NO;
    }
}

/**
 * return YES if replacementString is valid
 *
 */
- (BOOL)validatedString:(NSString *)replacementString {
    NSString *validCharacters = self.validCharacters;
    if (!validCharacters || [validCharacters isEqualToString:@""]) {
        return YES;
    }
    
    BOOL isBackspace = [replacementString isEqualToString:@""];
    BOOL isStringNotValid = [validCharacters rangeOfString:replacementString].location == NSNotFound;
    if (isBackspace)  {
        return YES;
    } else if (isStringNotValid) {
        return NO;
    } else {
        return YES;
    }
}

@end
