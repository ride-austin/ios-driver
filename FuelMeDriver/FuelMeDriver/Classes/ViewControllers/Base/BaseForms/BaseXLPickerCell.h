//
//  BaseXLPickerCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLTableViewCell.h"

@interface BaseXLPickerCell : BaseXLTableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lbTitle;
@property (nonatomic, weak) IBOutlet UILabel *lbPlaceholder;
@property (nonatomic, weak) IBOutlet UILabel *lbValue;
@end
