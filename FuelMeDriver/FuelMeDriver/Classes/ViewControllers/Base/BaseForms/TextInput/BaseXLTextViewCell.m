//
//  BaseXLTextViewCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/29/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTextViewCell.h"

NSString * const XLFormRowDescriptorTypeBaseXLTextViewCell = @"XLFormRowDescriptorTypeBaseXLTextViewCell";

@interface BaseXLTextViewCell(UITextViewDelegate) <UITextViewDelegate>
@end
@interface BaseXLTextViewCell()
/**
 *  @property needed to know when to resize the tableView
 */
@property (nonatomic) CGFloat previousCellHeight;
@end
@implementation BaseXLTextViewCell
+(void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeBaseXLTextViewCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}
- (void)configure {
    [super configure];
    self.textView.delegate = self;
    self.placeholderView.textColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1];
    [self bringSubviewToFront:self.placeholderView];
}
- (void)update {
    [super update];
    
    self.lbTitle.text   = self.rowDescriptor.title;
    self.textView.text  = [self.rowDescriptor.value displayText];
    self.placeholderView.text = self.rowDescriptor.noValueDisplayText;
    BOOL hasNoValue = !self.rowDescriptor.value || [self.rowDescriptor.value displayText].length == 0;
    self.placeholderView.hidden = !hasNoValue;
    
    [self configureDefaults];
    [self configureBasedOnTextFieldModel];
    [self updateHeight];
}
- (void)configureDefaults {
    self.textView.editable = self.rowDescriptor.isDisabled == NO;
}
- (void)configureBasedOnTextFieldModel {
    TextFieldModel *model = self.textFieldModel;
    self.textView.keyboardType           = model.keyboardType;
    self.textView.secureTextEntry        = model.isSecureTextEntry;
    self.textView.autocorrectionType     = model.autocorrectionType;
    self.textView.autocapitalizationType = model.autocapitalizationType;
}
- (CGFloat)cellHeight {
    CGFloat maxTextWidth = [UIScreen mainScreen].bounds.size.width - CGRectGetMinX(self.textView.frame)*2;
    CGSize titleSize = [self.textView sizeThatFits:CGSizeMake(maxTextWidth, CGFLOAT_MAX)];
    CGFloat topMargin = CGRectGetMinY(self.textView.frame);
    CGFloat bottomMargin = 15;
    CGFloat height = topMargin + titleSize.height + bottomMargin;
    return MAX(44, height);
}
- (void)updateHeight {
    if (self.previousCellHeight == 0) {
        self.previousCellHeight = self.cellHeight;
    }
    self.rowDescriptor.height = self.cellHeight;
    if (self.rowDescriptor.height != self.previousCellHeight) {
        self.previousCellHeight = self.rowDescriptor.height;
        [self didChangeHeight];
    }
}
- (void)didChangeHeight {
    UITableView *tableView = [self.formViewController tableView];
    [tableView beginUpdates];
    [tableView endUpdates];
}
#pragma mark - Responder
-(BOOL)canBecomeFirstResponder {
    return [self.rowDescriptor isDisabled] == NO;
}
-(BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}
-(BOOL)formDescriptorCellCanBecomeFirstResponder {
    return self.canBecomeFirstResponder;
}
-(BOOL)formDescriptorCellBecomeFirstResponder {
    return self.becomeFirstResponder;
}
-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self becomeFirstResponder];
}
@end
@implementation BaseXLTextViewCell (UITextViewDelegate)

-(void)textViewDidBeginEditing:(UITextView *)textView {
    self.placeholderView.hidden = YES;
    [self.formViewController beginEditing:self.rowDescriptor];
    return [self.formViewController textViewDidBeginEditing:textView];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self updateRowValueWithTextView:textView];
    [self.formViewController endEditing:self.rowDescriptor];
    [self.formViewController textViewDidEndEditing:textView];
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return [self.formViewController textViewShouldBeginEditing:textView];
}
-(void)textViewDidChange:(UITextView *)textView {
    [self updateRowValueWithTextView:textView];
}
-(void)updateRowValueWithTextView:(UITextView *)textView {
    if (textView.text.length > 0) {
        self.rowDescriptor.value = textView.text;
    } else {
        self.rowDescriptor.value = nil;
    }
    [self update];
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.textFieldModel.maxCharacters) {
        NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if (newText.length > self.textFieldModel.maxCharacters.integerValue) {
            return NO;
        }
    }
    return [self.formViewController textView:textView shouldChangeTextInRange:range replacementText:text];
}
@end
