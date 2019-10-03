//
//  CFReasonDataModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 3/24/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface CFReasonDataModel : RABaseDataModel

@property (nonatomic, readonly) NSString *code;
@property (nonatomic, readonly) NSString *reasonDescription;

@end
