//
//  WeekDayRides.m
//  RideDriver
//
//  Created by Carlos Alcala on 7/25/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "WeekDayRides.h"

@implementation WeekDayRides

- (instancetype)initWithDate:(NSDate *)date andRides:(NSArray<RideFareDataModel*> *)rides {
    if (self = [super init]) {
        self.rides = [NSArray new];
        self.date = date;
        self.rides = rides;
        
        //calculate totals
        [self calculateTotals];
    }
    return self;
}


- (void)calculateTotals {
    double totalTips = 0;
    double totalFare = 0;
    double totalRAFee = 0;
    double totalEarnings = 0;
    
    self.totalTrips = [NSNumber numberWithInteger:self.rides.count];
    
    for (RideFareDataModel *ride in self.rides) {
        totalTips += ride.tip.doubleValue;
        totalFare += [ride.subTotal doubleValue];
        totalRAFee += [ride.raFee doubleValue];
        totalEarnings += [ride.driverPayment doubleValue];
    }
    
    self.totalTips = [NSNumber numberWithDouble:totalTips];
    self.totalFare = [NSNumber numberWithDouble:totalFare];
    self.totalRAFee = [NSNumber numberWithDouble:totalRAFee];
    self.totalEarnings = [NSNumber numberWithDouble:totalEarnings];
}

@end
