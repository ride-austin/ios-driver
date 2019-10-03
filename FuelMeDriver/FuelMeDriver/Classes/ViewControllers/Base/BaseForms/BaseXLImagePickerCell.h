//
//  BaseXLImagePickerCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTableViewCell.h"

extern NSString * const XLFormRowDescriptorTypeBaseXLImagePickerCell;

@interface BaseXLImagePickerCell : BaseXLTableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lbTitle;
@property (nonatomic, weak) IBOutlet UIImageView *ivValue;
@property (nonatomic, weak) IBOutlet UIImageView *ivPlaceholder;
@end
