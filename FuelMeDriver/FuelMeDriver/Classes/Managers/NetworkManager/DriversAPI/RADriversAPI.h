//
//  RADriversAPI.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "Car.h"
#import "RABaseAPI.h"
#import "RACarCategoryDataModel.h"
#import "RADocument.h"
#import "RADriverDataModel.h"
#import "RADriverStatDataModel.h"
#import "RADriverType.h"

typedef void(^DriverStatisticBlock)(NSArray<RADriverStatDataModel *> *driverStatistics, NSError *error);

@interface RADriversAPI : RABaseAPI

+ (void)getDriversCurrentWithCompletion:(void(^)(RADriverDataModel *driver, NSError *error))completion;

/**
 this method duplicates [NetworkManager getCarsOfDriverWithID]
 */
+ (void)getSelectedCarWithCompletion:(void(^)(Car *selectedCar, NSError *error))completion;

#pragma mark - Statistics
+ (void)getStatisticForDriverWithId:(NSString *)driverId completion:(DriverStatisticBlock)completion;

#pragma mark - Earnings
+ (void)getRideFaresForDriverWithId:(NSNumber *)driverID withParams:(NSDictionary *)params andCompletion:(void(^)(NSDictionary*response, NSError* error))handler;
+ (void)getOnlineTimeForDriver:(NSNumber *)driverID withParams:(NSDictionary *)params andCompletion:(void(^)(NSDictionary*response, NSError* error))handler;

#pragma mark - Refer a driver
+ (void)postReferAFriendByEmail:(NSString *)email withCompletion:(void (^)(id, NSError *))completion;
+ (void)postReferAFriendBySMS:(NSString *)phone withCompletion:(void (^)(id, NSError *))completion;

#pragma mark - DriversDocuments
+ (void)postDocumentPhoto:(UIImage *)image withPhotoType:(NSString *)photoType expirationDate:(NSDate *)expirationDate andCarId:(NSString *)carId atCityId:(NSNumber *)cityId completion:(void(^)(NSError *error))completion;
+ (void)getDocumentWithPhotoType:(NSString *)photoType completion:(void (^)(RADocument *, NSError *))completion;
+ (void)getDocumentWithPhotoType:(NSString *)photoType withCarId:(NSString *)carId completion:(void(^)(RADocument *document, NSError *error))completion;

+ (void)updateDocument:(RADocument *)document withCompletion:(void(^)(NSError *error))completion;

#pragma mark - Car types
+ (void)getCarTypesForCity:(NSNumber *)cityID withCompletion:(void (^)(NSArray<RACarCategoryDataModel *> *carTypes, NSError *error))completion;

#pragma mark - Driver types
+ (void)getDriverTypesForCity:(NSNumber *)cityID withCompletion:(void (^)(NSArray<RADriverType *> *driverTypes, NSError *error))completion;

#pragma mark - Direct Connect
+ (void)getNewDriverConnectIdWithCompletion:(void(^)(NSString *driverConnectId, NSError *error))completion;

@end

