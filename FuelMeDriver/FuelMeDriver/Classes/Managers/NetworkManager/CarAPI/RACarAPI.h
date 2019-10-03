//
//  RACarAPI.h
//  RideAustin
//
//  Created by Carlos Alcala on 01/24/17.
//  Copyright © 2017 Crossover Markets Inc. All rights reserved.
//

#import "RABaseAPI.h"
#import "RACarDataModel.h"

typedef void(^RACarsAPICompletionBlock)(NSArray <RACarDataModel*> *cars, NSError* error);

@interface RACarAPI : RABaseAPI

+ (void)getAllCarsWithCompletion:(RACarsAPICompletionBlock)handler;

@end
