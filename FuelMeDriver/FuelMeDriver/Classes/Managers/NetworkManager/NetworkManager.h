//
//  NetworkManager.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 7/25/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Car.h"
#import "ConfigGlobal.h"
#import "RACity.h"
#import "RACityDetail.h"
#import "RADocument.h"
#import "RASupportTopic.h"
#import "SurgeArea.h"
#import "URLFactory.h"

typedef void (^CompleteBlock)(NSString *resourceId, NSInteger statusCode, NSError *error);

typedef void (^UploadDataCompleteBlock)(NSString* photoUrl, NSError *error);
typedef void (^UploadDataProgressBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void (^DriveCompleteBlock)(NSInteger statusCode, NSError *error);
typedef void (^DriveSnapCompleteBlock)(NSInteger statusCode, CLLocation *snappedLoc, NSError *error);

typedef void (^GetDriverRidesCompletionBlock)(NSDictionary*ridesDict, NSError* error);
typedef void (^GetRideMapURLCompletionBlock)(NSDictionary*mapURLDict, NSError* error);
typedef void (^CarPhotoCompletionBlock)(NSArray*cars, NSError* error);
typedef void (^CarPhotoDeleteCompletionBlock)(NSDictionary*object, NSError* error);
typedef void (^CarsCompletionBlock)(NSArray<Car*> *cars, NSError *error);
typedef void (^CarCreationCompletionBlock)(NSError *error);
typedef void (^CarPhotoUploaded)(id object,NSString *filePath,NSError *error);
typedef void (^DocumentFileCompletion)(NSString *photoURL,NSError *error);
typedef void (^DocumentCompletion)(NSError *error);
typedef void (^GetDocumentBlock)(RADocument*,NSError*);

@interface NetworkManager : NSObject

+ (NetworkManager*)sharedInstance;
- (void)postPath:(NSString*)path params:(NSDictionary*)params completeBlock:(CompleteBlock)completeBlock;
- (void)putPath:(NSString*)path params:(NSDictionary*)params completeBlock:(CompleteBlock)completeBlock;
- (void)deletePath:(NSString*)path params:(NSDictionary*)params completeBlock:(CompleteBlock)completeBlock;
- (BOOL)isNetworkReachable;

#pragma mark - Queues

- (void)getPositionForDriver:(NSNumber *)driverId withCompletion:(void (^)(NSDictionary *object, NSError *error))completionHandler;

#pragma mark - Surge Pricing

- (void)getSurgeAreas:(void (^)(NSArray<SurgeArea*>*areasArray, NSError *error))completionHandler;

#pragma mark - Driver Photo Upload Image

- (void)postDriverPhotoWithParams:(NSDictionary *)params
                      andDriverID:(NSString *)driverID
              uploadCompleteBlock:(UploadDataCompleteBlock)completionBlock;

#pragma mark - Car Photos

- (void)getCarPhotosWithCarID:(NSString*)carID andCompletionBlock:(CarPhotoCompletionBlock)block;
- (void)postCarPhotoWithParams:(NSDictionary *)params
                      andCarID:(NSString *)carID
                    andCarType:(NSString*)type
           uploadCompleteBlock:(UploadDataCompleteBlock)completionBlock;
- (void)deleteCarPhotoWithCarPhotoID:(NSString*)carPhotoID andCompletionBlock:(CarPhotoDeleteCompletionBlock)block;

#pragma mark - Cars

- (void)getCarsOfDriverWithID:(NSString*)driverID andCompletionBlock:(CarsCompletionBlock)block;
- (void) addCarInformationWithPath:(NSString*)path carData:(NSData * )carData photoData:(NSData*)photoData completeBlock:(void (^)(Car *car, NSError *error))block;
- (void)selectCarWithCarID:(NSString*)carID andDriverID:(NSString*)driverID andCompletionBlock:(void (^)(id object, NSError *error))block;
- (void)updateCar:(Car*)car withDriverID:(NSString*)driverID completion:(void(^)(NSError *error))completion;


#pragma mark - City Detail

+ (void)getCityDetailWithID:(NSNumber *)cityID withCompletion:(void (^)(RACityDetail *cityDetail, NSError *error))handler;


#pragma mark - Push Notifications Device Token

+ (void)registerDeviceToken:(NSString *)token andDeviceID:(NSString *)deviceID;

#pragma mark - Get Driver Terms & Condition

+ (void)getDriverTermsAtURL:(NSURL *)termsURL WithCompletion:(void (^)(NSString *, NSError *))completion;
+ (void)acceptTermsWithId:(NSString*)termId withCompletion:(void(^)(NSError *))completion;

@end

