//
//  DriverStatusButton.h
//  RideDriver
//
//  Created by Marcos Alba on 7/6/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DriverStatusButtonState){
    DABSOffline = 0,
    DABSOnline,
    DABSSync,
    DABSLoading,
    DABSDisabled,
    DABSHidden
};

@interface DriverStatusButton : UIButton

@property (nonatomic) DriverStatusButtonState status;

- (void)setStatusBasedOnAvailability;

@end
