//
//  BaseXLButtonCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTableViewCell.h"

extern NSString * const XLFormRowDescriptorTypeBaseXLButtonCell;

@interface BaseXLButtonCell : BaseXLTableViewCell
@property (weak, nonatomic) IBOutlet UIButton *button;
@end
