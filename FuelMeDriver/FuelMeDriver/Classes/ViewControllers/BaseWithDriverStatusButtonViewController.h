//
//  BaseWithDriverStatusButtonViewController.h
//  RideDriver
//
//  Created by Marcos Alba on 7/6/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "DriverStatusButton.h"

@protocol DriverStatusButtonProtocol <NSObject>

- (void)driverStatusButtonHasBeenPressed:(DriverStatusButton*)sender;

@end

@interface BaseWithDriverStatusButtonViewController : BaseViewController<DriverStatusButtonProtocol>

@property (nonatomic, readonly) DriverStatusButton *driverStatusButton;

- (void)placeDriverStatusButtonInNavigationBar;

@end
