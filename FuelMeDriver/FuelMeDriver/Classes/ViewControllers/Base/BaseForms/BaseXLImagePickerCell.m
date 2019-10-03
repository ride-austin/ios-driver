//
//  BaseXLImagePickerCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLImagePickerCell.h"

#import "RAPhotoPickerControllerManager.h"
#import "UIImage+Ride.h"
#import "RAAlertManager.h"


NSString * const XLFormRowDescriptorTypeBaseXLImagePickerCell = @"XLFormRowDescriptorTypeBaseXLImagePickerCell";
@interface BaseXLImagePickerCell()
@property (nonatomic) RAPhotoPickerControllerManager *pickerManager;
@end
@implementation BaseXLImagePickerCell
#pragma mark - XLFormLifeCycle
+(void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeBaseXLImagePickerCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}
-(void)configure {
    [super configure];
}

-(void)update {
    [super update];
    self.lbTitle.text = self.rowDescriptor.title;
    [self didUpdateRowDescriptorValue];
}
-(void)didUpdateRowDescriptorValue {
    BOOL hasValue = [self.rowDescriptor.value isKindOfClass:[UIImage class]];
    self.ivValue.image       = hasValue ? self.rowDescriptor.value : nil;
    self.ivValue.alpha       = hasValue;
    self.ivPlaceholder.alpha =!hasValue;
}
#pragma mark - XLFormRowDescriptor
-(UIView *)inputView {
    return nil;
}
-(BOOL)canBecomeFirstResponder {
    return [self.rowDescriptor isDisabled] == NO;
}
-(BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}
-(BOOL)resignFirstResponder {
    return [super resignFirstResponder];
}
-(BOOL)formDescriptorCellCanBecomeFirstResponder {
    return [self.rowDescriptor isDisabled] == NO;
}
-(BOOL)formDescriptorCellBecomeFirstResponder {
    if (self.isFirstResponder) {
        return self.resignFirstResponder;
    }
    return self.becomeFirstResponder;
}
-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
#ifdef AUTOMATION
    self.lbErrorMessage.text = @"";
    self.rowDescriptor.value = [UIImage imageNamed:@"iconCarBack"];
    [self didUpdateRowDescriptorValue];
    return;
#endif
    
    __weak __typeof__(self) weakself = self;
    [self.pickerManager showPickerControllerFromViewController:self.formViewController sender:self.ivPlaceholder allowEditing:YES finishedBlock:^(UIImage *picture, NSError *error) {
        weakself.lbErrorMessage.text = @"";
        BOOL valid = [weakself isImageValid:picture];
        if (valid) {
            CGFloat maxArea = 480000;
            picture = [UIImage imageWithImage:picture scaledToMaxArea:maxArea];
        }
        
        weakself.rowDescriptor.value = valid ? picture : nil;
        [weakself didUpdateRowDescriptorValue];
    } accessDeniedBlock:^(NSString * _Nonnull errorTitle, NSString * _Nonnull errorMessage) {
//
//        will think of a cleaner way to do this
//        // show error
//        [weakself animate];
//        weakself.lbErrorMessage.text = errorMessage;
//        weakself.lbErrorMessage.alpha = 1;
//        
//        // update value
//        weakself.rowDescriptor.value = nil;
//        [weakself didUpdateRowDescriptorValue];
        [RAAlertManager showErrorWithAlertItem:errorMessage andOptions:[RAAlertOption optionWithState:StateActive]];
    }];
}
+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 100;
}
-(RAPhotoPickerControllerManager *)pickerManager {
    if (!_pickerManager) {
        _pickerManager = [RAPhotoPickerControllerManager pickerManager];
    }
    return _pickerManager;
}
#pragma mark - Validation
- (BOOL)isImageValid:(UIImage *)image {
    if (image && [image imageValidSizeForMinArea:190*250]) {
        return YES;
    } else {
        NSString *message = @"Please upload a High Quality Photo with a minimum size of 190x250 pixels to be readable.";
        [RAAlertManager showErrorWithAlertItem:message
                                    andOptions:[RAAlertOption optionWithTitle:@"Invalid Size" andState:StateActive]];
        return NO;
    }
}
@end
