//
//  BaseXLPhonePickerCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTableViewCell.h"

extern NSString * const XLFormRowDescriptorTypeBaseXLPhonePickerCell;
@interface BaseXLPhonePickerCell : BaseXLTableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lbTitle;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@end
