//
//  BaseXLPhonePickerCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLPhonePickerCell.h"

#import "TextFieldModel.h"

#import "KLCPopup.h"
#import <MRCountryPicker/MRCountryPicker-Swift.h>

NSString * const XLFormRowDescriptorTypeBaseXLPhonePickerCell = @"XLFormRowDescriptorTypeBaseXLPhonePickerCell";

@interface PhonePickerValue : NSObject
@property (nonatomic) NSString *countryCode;
@property (nonatomic) NSString *phoneNumber;
- (NSString *)value;
@end

@interface BaseXLPhonePickerCell()
@property (nonatomic) PhonePickerValue *phonePickerModel;
//@property (strong, nonatomic) NSString *countryCode;

//country code
@property (weak, nonatomic) IBOutlet UIImageView *ivFlag;
@property (weak, nonatomic) IBOutlet UILabel *lbCountryCode;
@property (nonatomic) MRCountryPicker *countryPicker;

//text field
@property (nonatomic) TextFieldModel *textFieldModel;
@end
@interface BaseXLPhonePickerCell (CountryPicker) <MRCountryPickerDelegate>
- (void)configureCountryPicker;
@end
@interface BaseXLPhonePickerCell (TextField) <UITextFieldDelegate>
- (void)configureTextField;
@end
@implementation BaseXLPhonePickerCell
#pragma mark - XLFormLifeCycle
+(void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeBaseXLPhonePickerCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}
-(void)configure {
    [super configure];
    self.phonePickerModel = [PhonePickerValue new];
    [self configureCountryPicker];
    [self configureTextField];
}
-(void)update {
    [super update];
    [self configureBasedOnTextFieldModel];
    
    self.lbCountryCode.text = self.phonePickerModel.countryCode;
    self.textField.text     = self.phonePickerModel.phoneNumber;
    self.textField.enabled  = self.rowDescriptor.isDisabled == NO;
    
    //one time
    self.textField.placeholder = self.rowDescriptor.noValueDisplayText;
    self.lbTitle.text = self.rowDescriptor.title;
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
+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 67;
}
#pragma mark - Configurations
- (void)configureBasedOnTextFieldModel {
    self.textField.keyboardType           = self.textFieldModel.keyboardType;
    self.textField.secureTextEntry        = self.textFieldModel.isSecureTextEntry;
    self.textField.autocorrectionType     = self.textFieldModel.autocorrectionType;
    self.textField.autocapitalizationType = self.textFieldModel.autocapitalizationType;
    self.textField.clearButtonMode        = self.textFieldModel.clearButtonMode;
}
-(void)updateRowValue {
    self.rowDescriptor.value = self.phonePickerModel.value;
    DBLog(@"");
}
#pragma mark - Actions
-(IBAction)didTapCountry:(UIButton *)sender {
    [self.formViewController.view endEditing:YES];
    UIView *viewPicker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 237)];
    viewPicker.backgroundColor = [UIColor whiteColor];
    [viewPicker addSubview:self.countryPicker];
    KLCPopup *popupCountryPicker = [KLCPopup popupWithContentView:viewPicker
                                                         showType:KLCPopupShowTypeBounceIn
                                                      dismissType:KLCPopupDismissTypeBounceOut
                                                         maskType:KLCPopupMaskTypeDimmed
                                         dismissOnBackgroundTouch:YES
                                            dismissOnContentTouch:NO];
    [popupCountryPicker show];
}
@end
@implementation BaseXLPhonePickerCell (CountryPicker)
- (void)configureCountryPicker {
    self.countryPicker = [MRCountryPicker new];
    [self.countryPicker setCountryPickerDelegate:self];
    [self.countryPicker setCountry:@"US"];
}
#pragma mark - MRCountryPickerDelegate
-(void)countryPhoneCodePicker:(MRCountryPicker *)picker didSelectCountryWithName:(NSString *)name countryCode:(NSString *)countryCode phoneCode:(NSString *)phoneCode flag:(UIImage *)flag {
    self.ivFlag.image = flag;
    self.phonePickerModel.countryCode = phoneCode;
    [self update];
}
@end
@implementation BaseXLPhonePickerCell (TextField)
- (void)configureTextField {
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
    return [self.formViewController textField:textField shouldChangeCharactersInRange:range replacementString:string];
}

#pragma mark -UIControlEventEditingChanged
-(void)textFieldDidChange:(UITextField *)textField {
    if (self.textField == textField) {
        self.phonePickerModel.phoneNumber = self.textField.text;
        [self updateRowValue];
    }
}
@end

@implementation PhonePickerValue

-(NSString *)value {
    if (self.phoneNumber && self.phoneNumber.length > 0) {
        return [NSString stringWithFormat:@"%@%@", self.countryCode, self.phoneNumber];
    } else {
        return nil;
    }
}
@end
