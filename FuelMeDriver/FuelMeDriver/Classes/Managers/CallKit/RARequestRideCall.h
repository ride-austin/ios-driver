//
//  RARequestRideCall.h
//  RideDriver
//
//  Created by Kitos on 27/10/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RARequestRideCall : NSObject

@property (nonatomic, readonly) NSString *rideId;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSUUID *uuid;
@property (nonatomic) BOOL answered;
@property (nonatomic) BOOL declined;
@property (nonatomic, readonly, getter=isInProgress) BOOL inProgress;

- (instancetype)initWithName:(NSString *)name title:(NSString *)title rideId:(NSString *)rideId;

@end
