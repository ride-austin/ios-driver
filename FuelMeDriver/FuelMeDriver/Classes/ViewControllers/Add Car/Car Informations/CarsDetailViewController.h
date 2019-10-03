//
//  CarsDetailViewController.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/11/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "Car.h"

@interface CarsDetailViewController : BaseViewController

@property(nonatomic, retain) Car* car;
@property(nonatomic, retain) IBOutlet UITextField* license;

- (id)initWithYear:(NSString*)year make:(NSString*)make model:(NSString*)model color:(NSString*)color image:(UIImage*)image;

@end
