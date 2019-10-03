//
//  WeekDayRides.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/25/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RideFareDataModel.h"

@interface WeekDayRides : NSObject

//Properties
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSArray *rides;
@property (strong, nonatomic) NSNumber *totalTrips;
@property (strong, nonatomic) NSNumber *totalFare;
@property (strong, nonatomic) NSNumber *totalRAFee;
@property (strong, nonatomic) NSNumber *totalEarnings;
@property (strong, nonatomic) NSNumber *totalTips;


- (instancetype)initWithDate:(NSDate*)date andRides:(NSArray<RideFareDataModel *> *)rides;
- (void)calculateTotals;

@end
