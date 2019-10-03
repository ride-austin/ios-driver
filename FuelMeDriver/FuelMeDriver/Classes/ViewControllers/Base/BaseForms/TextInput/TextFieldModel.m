//
//  TextFieldModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "TextFieldModel.h"

@interface TextFieldModel()
@property (nonatomic, readwrite) UIKeyboardType keyboardType;
@property (nonatomic, readwrite) BOOL isSecureTextEntry;
@property (nonatomic, readwrite) UITextAutocorrectionType autocorrectionType;
@property (nonatomic, readwrite) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic, readwrite) UITextFieldViewMode clearButtonMode;

@property (nonatomic, readwrite) TextFieldInputType inputTypes;
@end
@implementation TextFieldModel
-(instancetype)init {
    if (self = [super init]) {
        _keyboardType           = UIKeyboardTypeDefault;
        _isSecureTextEntry      = NO;
        _autocorrectionType     = UITextAutocorrectionTypeNo;
        _autocapitalizationType = UITextAutocapitalizationTypeNone;
        _clearButtonMode        = UITextFieldViewModeWhileEditing;
        _maxCharacters          = @(255);
    }
    return self;
}
+(instancetype)details {
    TextFieldModel *model = [TextFieldModel new];
    model.inputTypes = letters | numbersEN | punctuations | symbols;
    return model;
}
+(instancetype)phone {
    TextFieldModel *model = [TextFieldModel new];
    model.inputTypes = numbersEN;
    model.keyboardType = UIKeyboardTypeNumberPad;
    return model;
}
-(NSString *)validCharacters {
    return [TextFieldOptions validCharactersForTypes:self.inputTypes];
}
@end
