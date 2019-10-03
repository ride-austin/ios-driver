//
//  CarSelectionHeader.h
//  RideDriver
//
//  Created by Abdul Rehman on 12/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarSelectionHeader : UITableViewHeaderFooterView

@property (nonatomic,weak) IBOutlet UILabel *carName;
@property (nonatomic,weak) IBOutlet UIButton *btnSelection;
@property (nonatomic,weak) IBOutlet UIImageView *imgCar;

@end
