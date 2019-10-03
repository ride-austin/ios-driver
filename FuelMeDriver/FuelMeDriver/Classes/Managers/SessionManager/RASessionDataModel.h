//
//  RASessionDataModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RADriverDataModel.h"
#import "DriverType.h"

@interface RASessionDataModel : RABaseDataModel
@property (nonatomic, nullable, readonly, copy) NSString *authToken;
@property (nonatomic, nullable, strong) RADriverDataModel *driver;
@property (nonatomic, nullable) NSArray<NSString *> *userCarTypes;
@property (nonatomic) DriverType driverTypeFilter;

@end

@interface RASessionDataModel (Three_dot_six_compatibility)

- (instancetype _Nonnull)initWithAuthToken:(NSString * _Nonnull)token;

@end


@interface RASessionDataModel (Preferences)

- (void)restorePreferencesForEmail:(NSString * _Nonnull)email;
- (void)cachePreferencesToEmail;

@end


@interface RASessionDataModel (AcknowledgedRides)

/**
 RA-1489 & RA-2154 & RA-14490
 show notification about cancelled ride if the app has acknowledged it
 */
- (BOOL)shouldShowCancelledRide:(NSNumber * _Nonnull)cancelledRideId;
- (void)acknowledgeRide:(NSNumber * _Nonnull)rideId;
- (void)terminateRide:(NSNumber * _Nonnull)rideId;

@end
