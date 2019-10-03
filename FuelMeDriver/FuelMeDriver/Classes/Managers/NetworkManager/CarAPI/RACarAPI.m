//
//  RACarAPI.m
//  RideAustin
//
//  Created by Carlos Alcala on 01/24/17.
//  Copyright © 2017 Crossover Markets Inc. All rights reserved.
//

#import "RACarAPI.h"

@implementation RACarAPI

+ (void)getAllCarsWithCompletion:(RACarsAPICompletionBlock)handler {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RAConfigCars" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSError *parseError;
    NSArray *carsArrayJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
    if (!parseError) {
        NSArray <RACarDataModel *> *cars = [MTLJSONAdapter modelsOfClass:RACarDataModel.class fromJSONArray:carsArrayJSON error:&parseError];

        if (handler) {
            handler(cars,parseError);
        }
    } else {
        if (handler) {
            handler(nil,parseError);
        }
    }
}

@end
