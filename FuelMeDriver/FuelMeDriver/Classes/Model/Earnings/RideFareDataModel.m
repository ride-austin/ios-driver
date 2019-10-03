//
//  RideFareDataModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/8/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RideFareDataModel.h"

#import "NSNumber+UTC.h"

@implementation RideFareDataModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    if (self = [super initWithDictionary:dictionaryValue error:error]) {
        if ([_start isKindOfClass:RARideAddressDataModel.class]) {
            [_start setLocationByCoordinate:CLLocationCoordinate2DMake(_startLocationLat.doubleValue, _startLocationLng.doubleValue)];
        }
        
        if ([_end isKindOfClass:RARideAddressDataModel.class]) {
            [_end setLocationByCoordinate:CLLocationCoordinate2DMake(_endLocationLat.doubleValue, _endLocationLng.doubleValue)];
        }
        
        if (!_tip) {
            _tip = [NSNumber numberWithDouble:0.0];
        }
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"surgeFare" : @"surgeFare",
              @"subTotal" : @"subTotal",
              @"endLocationLat" : @"endLocationLat",
              @"status" : @"status",
              @"startedOn" : @"startedOn",
              @"cityFee" : @"cityFee",
              @"cancelledOn" : @"cancelledOn",
              @"driverRating" : @"driverRating",
              @"completedOn" : @"completedOn",
              @"surgeFactor" : @"surgeFactor",
              @"car" : @"car",
              @"raFee" : @"raFee",
              @"endLocationLng" : @"endLocationLng",
              @"startLocationLat" : @"startLocationLat",
              @"modelID" : @"id",
              @"ratePerMile" : @"ratePerMile",
              @"roundUpAmount" : @"roundUpAmount",
              @"driverPayment" : @"driverPayment",
              @"totalFare" : @"totalFare",
              @"requestedCarType" : @"requestedCarType",
              @"startLocationLng" : @"startLocationLng",
              @"end" : @"end",
              @"rideMap" : @"rideMap",
              @"distanceFare" : @"distanceFare",
              @"tip" : @"tip",
              @"minimumFare" : @"minimumFare",
              @"start" : @"start",
              @"baseFare" : @"baseFare",
              @"ratePerMinute" : @"ratePerMinute",
              @"timeFare" : @"timeFare",
              @"bookingFee" : @"bookingFee"
            };
}

#pragma mark - Transfomers

+ (NSValueTransformer *)surgeFareJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)surgeFactorJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)subTotalJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)baseFareJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)ratePerMinuteJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)timeFareJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)bookingFeeJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)raFeeJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)totalFareJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)tipJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)minimumFareJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)distanceFareJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)driverPaymentJSONTransformer {
    return [super stringToNumberTransformer];
}

+ (NSValueTransformer *)startedOnJSONTransformer {
    return [super numberToDateTransformer];
}

+ (NSValueTransformer *)cancelledOnJSONTransformer {
    return [super numberToDateTransformer];
}

+ (NSValueTransformer *)completedOnJSONTransformer {
    return [super numberToDateTransformer];
}

+ (NSValueTransformer *)carJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RACarDataModel class]];
}

+ (NSValueTransformer *)requestedCarTypeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RACarCategoryDataModel class]];
}

+ (NSValueTransformer*)startAddressJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RARideAddressDataModel class]];
}

+ (NSValueTransformer*)endAddressJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RARideAddressDataModel class]];
}

#pragma mark - Methods

- (BOOL)isRideCancelled {
    return self.cancelledOn != nil;
}

- (BOOL)shouldShowInEarnings {
    return [self.status isEqualToString:@"COMPLETED"] || [self.status isEqualToString:@"RIDER_CANCELLED"] || [self.status isEqualToString:@"DRIVER_CANCELLED"];
}

- (NSDate *)dateToConsider {
    if (self.isRideCancelled) {
        return self.cancelledOn;
    }
    return self.completedOn ?: self.startedOn;
}

@end
