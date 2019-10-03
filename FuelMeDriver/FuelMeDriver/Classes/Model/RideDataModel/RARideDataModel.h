//
//  RARideDataModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RACarCategoryDataModel.h"
#import "DriverType.h"
#import "RADriverType.h"
#import "RARideAddressDataModel.h"
#import "RARiderDataModel.h"
#import "RideRequestUpgrade.h"

@interface RARideDataModel : RABaseDataModel

@property (nonatomic) NSNumber *surgeFactor;
@property (nonatomic) NSString *comment;
@property (nonatomic) RARiderDataModel *rider;
@property (nonatomic) RARideAddressDataModel *startAddress;
@property (nonatomic) RARideAddressDataModel *endAddress;
@property (nonatomic) RACarCategoryDataModel *requestedCarType;
@property (nonatomic) RideRequestUpgrade *rideRequestUpgrade;
@property (nonatomic) NSNumber *driverPayment;
@property (nonatomic) RARideDataModel *nextRide;
@property (nonatomic) NSString *status;
@property (nonatomic) NSArray<RADriverType *> *requestedDriverTypes;

- (NSString *)eta;
- (BOOL)containsDriverType:(DriverType)driverType;
- (BOOL)hasSurgeFactor;
- (BOOL)isValid;
- (void)upgradeRequestWithTarget:(NSString *)target;

@end

@interface RARideDataModel (EventStubGenerator)

+ (instancetype)rideFromFileName:(NSString *)fileName;
- (NSDictionary *)jsonObject;

@end
