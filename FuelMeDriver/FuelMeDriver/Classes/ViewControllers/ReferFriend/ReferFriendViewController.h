//
//  ReferFriendViewController.h
//  RideDriver
//
//  Created by Carlos Alcala on 9/13/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@interface ReferFriendViewController : BaseViewController

//IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *driverStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *carLabel;
@property (weak, nonatomic) IBOutlet UILabel *referFriendLabel;
@property (weak, nonatomic) IBOutlet UIButton *toggleStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *referButton;

@end
