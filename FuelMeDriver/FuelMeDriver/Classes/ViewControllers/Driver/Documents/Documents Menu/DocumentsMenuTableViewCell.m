//
//  DocumentsMenuTableViewCell.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 2/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "DocumentsMenuTableViewCell.h"

@implementation DocumentsMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureCell];
}

- (void)configureCell {
    self.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
    self.textLabel.font       = [UIFont fontWithName:@"Montserrat-Regular" size:14];
    self.textLabel.textColor  = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
    self.selectionStyle       = UITableViewCellSelectionStyleBlue;
    self.detailTextLabel.font = [UIFont fontWithName:@"Montserrat-Light"   size:10];
    self.detailTextLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
