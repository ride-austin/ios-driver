//
//  RASessionDataModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RASessionDataModel.h"

#import "PersistenceManagerConstants.h"

@interface RASessionDataModel()

@property (nonatomic) NSMutableArray <NSNumber *> *acknowledgedRides;

@end

@implementation RASessionDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"authToken" : @"token", //only one returned by RASessionAPI
             @"driver"    : @"driver",
             @"userCarTypes" : @"userCarTypes",
             @"driverTypeFilter" : @"driverTypeFilter",
             @"acknowledgedRides" : @"acknowledgedRides"
            };
}

- (NSArray<NSString *> *)userCarTypes {
    if (!_userCarTypes) {
        _userCarTypes = _driver.selectedCar.carCategories;
    }
    return _userCarTypes;
}

@end

@implementation RASessionDataModel (Three_dot_six_compatibility)

- (instancetype)initWithAuthToken:(NSString *)token {
    if (self = [super init]) {
        _authToken = token;
    }
    return self;
}

@end

@implementation RASessionDataModel (Preferences)

- (void)restorePreferencesForEmail:(NSString *)email {
    if ([email isKindOfClass:NSString.class]) {
        NSString *key = [email stringByAppendingString:kCachedUserCarTypes];
        _userCarTypes = [[NSUserDefaults standardUserDefaults] arrayForKey:key];
    }
}

- (void)cachePreferencesToEmail {
    if ([self.driver.email isKindOfClass:NSString.class]) {
        NSString *key = [self.driver.email stringByAppendingString:kCachedUserCarTypes];
        [[NSUserDefaults standardUserDefaults] setObject:_userCarTypes forKey:key];
    }
}

@end

@implementation RASessionDataModel (AcknowledgedRides)

- (BOOL)shouldShowCancelledRide:(NSNumber *)cancelledRideId {
    BOOL shouldShowNotification = [self.acknowledgedRides containsObject:cancelledRideId];
    if (shouldShowNotification) {
        [self terminateRide:cancelledRideId];
    }
    return shouldShowNotification;
}

- (void)acknowledgeRide:(NSNumber *)rideId {
    if (!rideId) {
        NSAssert(rideId, @"rideId is not expected to be nil");
        return;
    }
    
    if (!self.acknowledgedRides) {
        self.acknowledgedRides = [NSMutableArray new];
    }
    [self.acknowledgedRides addObject:rideId];
}

- (void)terminateRide:(NSNumber *)rideId {
    [self.acknowledgedRides removeObject:rideId];
}

@end
