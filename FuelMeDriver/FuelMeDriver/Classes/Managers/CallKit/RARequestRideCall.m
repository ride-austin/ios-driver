//
//  RARequestRideCall.m
//  RideDriver
//
//  Created by Kitos on 27/10/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RARequestRideCall.h"

@interface RARequestRideCall ()

@property (nonatomic, strong) NSString *rideId;
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;

@end

@implementation RARequestRideCall

- (instancetype)initWithName:(NSString *)name title:(NSString *)title rideId:(NSString *)rideId {
    self = [super init];
    if (self) {
        _rideId = rideId;
        _name = name;
        _title = title;
        _uuid = [NSUUID UUID];
        _answered = NO;
        _declined = NO;
    }
    return self;
}

- (BOOL)isInProgress {
    return !self.answered && !self.declined;
}

@end
