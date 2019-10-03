//
//  WeeklyTotalCell.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/25/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeeklyTotalCell : UITableViewCell

//IBoutlets
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

//Configuration
- (void)configureCellWithTotal:(NSNumber *)total;

@end
