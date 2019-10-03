//
//  RACarCategoryConfigurationModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RACarCategoryConfigurationModel : RABaseDataModel

@property (nonatomic, readonly) BOOL disableCancellationFee;
@property (nonatomic, readonly) NSNumber *supportsAreaQueue; //if nil, supportsAreaQueue is yes by default

@end
