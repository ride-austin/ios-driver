//
//  BaseXLPickerCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLPickerCell.h"

@interface BaseXLPickerCell() <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic) UIPickerView *pickerView;
@end

@implementation BaseXLPickerCell
#pragma mark - XLFormDescriptorCell
-(void)configure {
    [super configure];
}

-(void)update {
    [super update];
    
    self.lbTitle.text = self.rowDescriptor.title;
    [self didUpdateRowDescriptorValue];
}
-(void)didUpdateRowDescriptorValue {
    if (self.rowDescriptor.value != nil) {
        self.lbValue.text = [self valueDisplayText];
        self.lbPlaceholder.text = @"";
    } else {
        self.lbValue.text = @"";
        self.lbPlaceholder.text = self.rowDescriptor.noValueDisplayText;
    }
}
- (NSString *)valueDisplayText {
    if (self.selectedIndex >= 0) {
        XLFormOptionsObject *option = self.rowDescriptor.selectorOptions[self.selectedIndex];
        return option.displayText;
    } else {
        return nil;
    }
}
#pragma mark - XLFormRowDescriptor
-(UIView *)inputView {
    return self.pickerView;
}
-(BOOL)formDescriptorCellCanBecomeFirstResponder {
    return self.rowDescriptor.isDisabled == NO;
}
-(BOOL)formDescriptorCellBecomeFirstResponder {
    return [self becomeFirstResponder];
}
-(BOOL)canBecomeFirstResponder {
    return self.rowDescriptor.isDisabled == NO;
}

#pragma mark - PickerView
-(UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [UIPickerView autolayoutView];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        if (self.selectedIndex > 0) {
            [_pickerView selectRow:self.selectedIndex inComponent:0 animated:NO];
        } else {
            [self initializeRowDescriptorValueIfNeeded];
        }
    }
    return _pickerView;
}
-(void)initializeRowDescriptorValueIfNeeded {
    self.rowDescriptor.value = [self.rowDescriptor.selectorOptions.firstObject valueData];
    [self didUpdateRowDescriptorValue];
}
#pragma mark UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.rowDescriptor.selectorOptions.count;
}

#pragma mark UIPickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.rowDescriptor.selectorOptions[row] displayText];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.rowDescriptor.value = [self.rowDescriptor.selectorOptions[row] valueData];
    [self didUpdateRowDescriptorValue];
    [self setNeedsLayout];
}
#pragma mark - helpers
-(NSInteger)selectedIndex {
    XLFormRowDescriptor *row = self.rowDescriptor;
    if (row.value) {
        for (id option in row.selectorOptions) {
            if ([[option valueData] isEqual:row.value]) {
                return [row.selectorOptions indexOfObject:option];
            }
        }
    }
    return -1;
}
@end
