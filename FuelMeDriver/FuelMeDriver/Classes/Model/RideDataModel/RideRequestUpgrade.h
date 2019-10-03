//
//  RideRequestUpgrade.h
//  RideDriver
//
//  Created by Roberto Abreu on 6/14/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"

typedef NS_ENUM(NSUInteger,UpgradeStatus) {
    UpgradeRequested,
    UpgradeDeclined,
    UpgradeAccepted,
    UpgradeInvalid
};

@interface RideRequestUpgrade : RABaseDataModel

@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *target;
@property (nonatomic, assign) UpgradeStatus status;
@property (nonatomic, readonly) NSString *targetName;

@end
