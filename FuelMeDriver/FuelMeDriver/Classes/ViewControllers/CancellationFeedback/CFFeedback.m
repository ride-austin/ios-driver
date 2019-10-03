//
//  CFFeedback.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 3/29/18.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

#import "CFFeedback.h"

@implementation CFFeedback
- (instancetype)initWithRide:(NSNumber *)rideID {
    self = [super init];
    if (self) {
        _rideID = rideID.stringValue;
    }
    return self;
}
+ (instancetype)feedbackForRide:(NSNumber *)rideID {
    return [[self alloc] initWithRide:rideID];
}
@end
