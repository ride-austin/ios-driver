//
//  ReportStatsCell.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/18/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportStatsCell : UITableViewCell

//IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *ratingButton;
@property (weak, nonatomic) IBOutlet UILabel *tripsLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;

//Helper Functions
- (void)configureCellWithRating:(NSNumber*)rating andTrips:(NSNumber*)trips andOnline:(NSNumber*)seconds;

@end
