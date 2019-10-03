//
//  RideFareDataModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/8/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RACarCategoryDataModel.h"
#import "RACarDataModel.h"
#import "RARideAddressDataModel.h"

@interface RideFareDataModel : RABaseDataModel

@property (nonatomic, readonly) NSNumber *surgeFare;
@property (nonatomic, readonly) NSNumber *subTotal;
@property (nonatomic, readonly) NSNumber *endLocationLat;
@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readwrite) NSDate *startedOn; //for testing
@property (nonatomic, readonly) NSString *cityFee;
@property (nonatomic, readonly) NSDate *cancelledOn;
@property (nonatomic, readonly) NSNumber *driverRating;
@property (nonatomic, readwrite) NSDate *completedOn; //for testing
@property (nonatomic, readonly) NSNumber *surgeFactor;
@property (nonatomic, readonly) RACarDataModel *car;
@property (nonatomic, readonly) NSNumber *raFee;
@property (nonatomic, readonly) NSNumber *endLocationLng;
@property (nonatomic, readonly) NSNumber *startLocationLat;
@property (nonatomic, readonly) NSString *ratePerMile;
@property (nonatomic, readonly) NSString *roundUpAmount;
@property (nonatomic, readonly) NSNumber *driverPayment;
@property (nonatomic, readonly) NSNumber *totalFare;
@property (nonatomic, readonly) RACarCategoryDataModel *requestedCarType;
@property (nonatomic, readonly) NSNumber *startLocationLng;
@property (nonatomic, readonly) RARideAddressDataModel *end;
@property (nonatomic, readonly) NSString *rideMap;
@property (nonatomic, readonly) NSNumber *distanceFare;
@property (nonatomic, readonly) NSNumber *tip;
@property (nonatomic, readonly) NSNumber *minimumFare;
@property (nonatomic, readonly) RARideAddressDataModel *start;
@property (nonatomic, readonly) NSNumber *baseFare;
@property (nonatomic, readonly) NSNumber *ratePerMinute;
@property (nonatomic, readonly) NSNumber *timeFare;
@property (nonatomic, readonly) NSNumber *bookingFee;

- (BOOL)isRideCancelled;
- (BOOL)shouldShowInEarnings;
- (NSDate *)dateToConsider;

@end
