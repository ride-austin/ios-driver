//
//  BaseXLTextFieldCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTableViewCell.h"
#import "TextFieldModel.h"

FOUNDATION_EXPORT NSString * const XLFormRowDescriptorTypeBaseXLTextFieldCell;
@interface BaseXLTextFieldCell : BaseXLTableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lbTitle;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic) TextFieldModel *textFieldModel;
@end
