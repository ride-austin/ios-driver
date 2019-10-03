//
//  RACarDatamodel.h
//  RideAustin
//
//  Created by Carlos Alcala on 01/24/17.
//  Copyright © 2017 Crossover Markets Inc. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RACarDataModel : RABaseDataModel

@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *year;

- (NSString*)fullDescription;

@end
