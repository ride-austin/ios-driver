//
//  LIFieldViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseXLBooleanPickerCell.h"
#import "BaseXLDatePickerCell.h"
#import "BaseXLImagePickerCell.h"
#import "BaseXLPhonePickerCell.h"
#import "BaseXLTextViewCell.h"
#import "LIMultiLineLabelCell.h"

@class LIFieldDataModel;
@class TextFieldModel;

@interface LIFieldViewModel : NSObject

@property (nonatomic, readonly) NSString *variable;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *placeholder;
@property (nonatomic, readonly) NSString *requireMsg;

+ (instancetype)viewModelWithDataModel:(LIFieldDataModel *)model;
- (NSString *)rowType;
- (id)model;

@end
