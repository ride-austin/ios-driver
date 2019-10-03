//
//  RAConfigApp.h
//  Ride
//
//  Created by Kitos on 8/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RAConfigAppDataModel : RABaseDataModel

@property (nonatomic, strong) NSString * avatar;
@property (nonatomic, strong) NSString * platform;
@property (nonatomic, strong) NSString * version;
@property (nonatomic, getter=isMandatory) BOOL mandatoryUpgrade;
@property (nonatomic, strong) NSString * userAgentHeader;
@property (nonatomic, strong) NSURL * upgradeURL;

@property (nonatomic, readonly) BOOL shouldUpgrade;
@property (nonatomic, readonly) BOOL mustUpgrade;

@end
