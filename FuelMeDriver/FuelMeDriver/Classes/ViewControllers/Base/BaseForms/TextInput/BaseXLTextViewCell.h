//
//  BaseXLTextViewCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/29/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTableViewCell.h"
#import "TextFieldModel.h"

FOUNDATION_EXPORT NSString * const XLFormRowDescriptorTypeBaseXLTextViewCell;
@interface BaseXLTextViewCell : BaseXLTableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lbTitle;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UITextView *placeholderView;
@property (nonatomic) TextFieldModel *textFieldModel;
@end
