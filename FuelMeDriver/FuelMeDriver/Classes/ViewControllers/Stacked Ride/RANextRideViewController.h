//
//  RANextRideViewController.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 12/21/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"
#import "RARideDataModel.h"

typedef void(^VoidBlock)(void);

@interface RANextRideViewController : BaseViewController

@property (nonatomic) RARideDataModel *nextRide;
@property (nonatomic, copy) VoidBlock dismissCompletion;

- (void)show;
- (void)dismiss;

@end
