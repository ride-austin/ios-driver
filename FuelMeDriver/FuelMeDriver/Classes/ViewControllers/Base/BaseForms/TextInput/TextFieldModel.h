//
//  TextFieldModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TextFieldOptions.h"

@interface TextFieldModel : NSObject
@property (nonatomic, readonly) UIKeyboardType keyboardType;
@property (nonatomic, readonly) BOOL isSecureTextEntry;
@property (nonatomic, readonly) UITextAutocorrectionType autocorrectionType;
@property (nonatomic, readonly) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic, readonly) UITextFieldViewMode clearButtonMode;
@property (nonatomic, readonly) TextFieldInputType inputTypes;
@property (nonatomic) NSNumber *maxCharacters;
@property (nonatomic) NSNumber *minimumCharacters;
- (NSString *)validCharacters;
+ (instancetype)details;
+ (instancetype)phone;
@end
