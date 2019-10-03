//
//  BaseXLDatePickerCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTableViewCell.h"

@class DatePickerModel;
extern NSString * const XLFormRowDescriptorTypeBaseXLDatePickerCell;
@interface BaseXLDatePickerCell : BaseXLTableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lbTitle;
@property (nonatomic, weak) IBOutlet UILabel *lbPlaceholder;
@property (nonatomic, weak) IBOutlet UILabel *lbValue;
@property (nonatomic) DatePickerModel *datePickerModel;
@end
