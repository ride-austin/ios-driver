//
//  BaseXLTextFieldCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTextFieldCell.h"

#import "NSObject+XLFormAdditions.h"
#import "UIView+XLFormAdditions.h"

NSString * const XLFormRowDescriptorTypeBaseXLTextFieldCell = @"XLFormRowDescriptorTypeBaseXLTextFieldCell";
@interface BaseXLTableViewCell() <UITextFieldDelegate>
@end
@implementation BaseXLTextFieldCell
+(void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeBaseXLTextFieldCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}
- (void)configure {
    [super configure];
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.textField.delegate = self;
}
- (void)update {
    [super update];
    
    self.lbTitle.text   = self.rowDescriptor.title;
    self.textField.text = [self.rowDescriptor.value displayText];
    self.textField.placeholder = self.rowDescriptor.noValueDisplayText;
    
    [self configureDefaults];
    [self configureBasedOnTextFieldModel];
}
- (void)configureDefaults {
    self.textField.enabled = self.rowDescriptor.isDisabled == NO;
}
- (void)configureBasedOnTextFieldModel {
    self.textField.keyboardType           = self.textFieldModel.keyboardType;
    self.textField.secureTextEntry        = self.textFieldModel.isSecureTextEntry;
    self.textField.autocorrectionType     = self.textFieldModel.autocorrectionType;
    self.textField.autocapitalizationType = self.textFieldModel.autocapitalizationType;
    self.textField.clearButtonMode        = self.textFieldModel.clearButtonMode;
}
#pragma mark -XLFormViewController
-(void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    self.textField.returnKeyType = returnKeyType;
}

-(UIReturnKeyType)returnKeyType {
    return self.textField.returnKeyType;
}
-(BOOL)formDescriptorCellCanBecomeFirstResponder {
    return self.rowDescriptor.isDisabled == NO;
}
-(BOOL)formDescriptorCellBecomeFirstResponder {
    return [self.textField becomeFirstResponder];
}
#pragma mark -UITextFieldDelegate
-(BOOL)textFieldShouldClear:(UITextField *)textField {
    return [self.formViewController textFieldShouldClear:textField];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [self.formViewController textFieldShouldReturn:textField];
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return [self.formViewController textFieldShouldBeginEditing:textField];
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return [self.formViewController textFieldShouldEndEditing:textField];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.formViewController beginEditing:self.rowDescriptor];
    [self.formViewController textFieldDidBeginEditing:textField];
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self textFieldDidChange:textField];
    [self.formViewController endEditing:self.rowDescriptor];
    [self.formViewController textFieldDidEndEditing:textField];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.textFieldModel.maxCharacters) {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (newText.length > self.textFieldModel.maxCharacters.integerValue) {
            return NO;
        }
    }
    return [self.formViewController textField:textField shouldChangeCharactersInRange:range replacementString:string];
}

#pragma mark -UIControlEventEditingChanged
-(void)textFieldDidChange:(UITextField *)textField {
    if (self.textField == textField) {
        if (self.textField.text.length > 0) {
            self.rowDescriptor.value = self.textField.text;
        } else {
            self.rowDescriptor.value = nil;
        }
    }
}
@end
