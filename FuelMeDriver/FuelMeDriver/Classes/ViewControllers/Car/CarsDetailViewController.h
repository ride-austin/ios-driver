//
//  CarsDetailViewController.h
//  RideDriver
//
//  Created by Adriano Alencar on 19/05/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "Car.h"

@interface CarsDetailViewController : BaseViewController

@property(nonatomic, retain) Car* car;

- (void)setDetails:(NSString*)year make:(NSString*)make model:(NSString*)model color:(NSString*)color image:(UIImage*)image;

@end
