//
//  SurgeAreaCar.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 4/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "SurgeAreaCar.h"

@implementation SurgeAreaCar
-(instancetype)initCarWithCategory:(NSString *)category andFactor:(NSNumber *)factor {
    self = [super init];
    if (self) {
        _category = category;
        _factor = factor;
    }
    return self;
}
+(instancetype)carWithCategory:(NSString *)category andFactor:(NSNumber *)factor {
    return [[self alloc] initCarWithCategory:category andFactor:factor];
}
-(BOOL)hasSurgeGreaterThanCar:(SurgeAreaCar *)car {
    if (self.factor.floatValue > 1) {
        if (car) {
            return self.factor.floatValue > car.factor.floatValue;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}
@end
