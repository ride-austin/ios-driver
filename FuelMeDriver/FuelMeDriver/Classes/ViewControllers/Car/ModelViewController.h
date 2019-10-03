//
//  RDModelViewController.h
//  RideDriver
//
//  Created by Adriano Alencar on 19/05/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "AbstractCarDetailViewController.h"

@interface ModelViewController : AbstractCarDetailViewController

@property (nonatomic, strong) NSString* make;
@property (nonatomic, strong) NSString* year;

@end
