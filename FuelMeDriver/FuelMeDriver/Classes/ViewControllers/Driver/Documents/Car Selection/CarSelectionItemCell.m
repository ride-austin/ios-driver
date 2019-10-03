//
//  CarSelectionItemCell.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "CarSelectionItemCell.h"

@implementation CarSelectionItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIColor *textColor = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
    self.detailTextLabel.textColor = textColor;
    self.textLabel.textColor = textColor;
    self.detailTextLabel.font = [UIFont fontWithName:@"Montserrat-Light" size:10];
    self.textLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12];
}

@end
