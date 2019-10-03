//
//  DriverStatisticViewController.h
//  RideDriver
//
//  Created by Roberto Abreu on 7/27/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@interface DriverStatisticViewController : BaseViewController <UITableViewDataSource>
@property (nonatomic, copy) NSString *driverID;
@end
