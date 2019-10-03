//
//  RideRate.m
//  RideDriver
//
//  Created by Roberto Abreu on 16/10/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RideRate.h"

@implementation RideRate

- (id)initWithRideId:(NSString *)rideId andRate:(CGFloat)rate {
    if (self = [super init]) {
        self.rideId = rideId;
        self.rate = rate;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if((self = [super init])) {
        self.rideId = [coder decodeObjectForKey:@"rideId"];
        self.rate = [coder decodeFloatForKey:@"rate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.rideId forKey:@"rideId"];
    [coder encodeFloat:self.rate forKey:@"rate"];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]] && [((RideRate*)object).rideId isEqualToString:self.rideId]) {
        return YES;
    }
    return NO;
}

@end
