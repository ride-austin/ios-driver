//
//  DailyTotalCell.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/18/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyTotalCell : UITableViewCell

//IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

//Helper Functions
- (void)configureCellWithTotal:(NSNumber*)total andDate:(NSDate*)date;

@end
