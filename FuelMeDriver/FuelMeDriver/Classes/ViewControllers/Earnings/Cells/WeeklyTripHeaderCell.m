//
//  WeeklyTripHeaderCell.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/25/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "WeeklyTripHeaderCell.h"

#import "ConfigurationManager.h"
#import "NSString+Utils.h"

@interface WeeklyTripHeaderCell()

@property (weak, nonatomic) IBOutlet UILabel *lbTotalRAFee;

@end

@implementation WeeklyTripHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lbTotalRAFee.text = [NSString stringWithFormat:[@"TOTAL %@\n FEE" localized], [ConfigurationManager appPrefix]];
}

@end
