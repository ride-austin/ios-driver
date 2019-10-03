//
//  RADriverStatDataModel.h
//  RideDriver
//
//  Created by Roberto Abreu on 7/27/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RADriverStatDataModel : RABaseDataModel

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *value;
@property (strong, nonatomic) NSNumber *outOfTotal;
@property (strong, nonatomic) NSString *statDescription;
@property (nonatomic, readonly) double rate;

@end
