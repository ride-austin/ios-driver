//
//  DriverStatisticTableViewCell.h
//  RideDriver
//
//  Created by Roberto Abreu on 7/27/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DriverStatisticTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblPercent;

@end
