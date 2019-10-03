//
//  BaseXLTableViewCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <XLForm/XLForm.h>

@interface BaseXLTableViewCell : XLFormBaseCell
@property (nonatomic) IBOutlet UILabel *lbErrorMessage;
- (void)animate;
@end
