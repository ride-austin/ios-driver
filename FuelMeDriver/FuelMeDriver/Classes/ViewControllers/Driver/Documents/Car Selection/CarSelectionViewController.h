//
//  CarSelectionViewController.h
//  RideDriver
//
//  Created by Abdul Rehman on 12/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "RACityDetail.h"

@interface CarSelectionViewController : BaseViewController

- (void)configureWithCityDetail:(RACityDetail *)cityDetail registeredCity:(RACity *)registeredCity andDriverID:(NSString *)driverID;
- (IBAction)btnAddCarPressed:(UIButton *)sender;

@end
