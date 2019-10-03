//
//  RADriversAPI.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RADriversAPI.h"

#import "ErrorReporter.h"
#import "NetworkManager.h"
#import "UIImage+Ride.h"

@implementation RADriversAPI

+ (void)getDriversCurrentWithCompletion:(void (^)(RADriverDataModel *, NSError *))completion {
    NSString *path = kPathDriversCurrent;
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    [client setParameterEncoding:AFRKFormURLParameterEncoding];
    [client getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            RADriverDataModel *driver = [RAJSONAdapter modelOfClass:RADriverDataModel.class fromJSONDictionary:responseObject isNullable:NO];
            completion(driver, nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETDriver];
        if (completion) {
            NSError *raError = [error filteredErrorAtReponse:operation.response];
            completion(nil, raError);
        }
    }];
}

+ (void)getDriverWithID:(NSString *)driverId completion:(void (^)(RADriverDataModel *, NSError *))completion {
    NSString *path = [NSString stringWithFormat:kPathDriversSpecific, driverId];
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    [client setParameterEncoding:AFRKFormURLParameterEncoding];
    [client getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            RADriverDataModel *driver = [RAJSONAdapter modelOfClass:RADriverDataModel.class fromJSONDictionary:responseObject isNullable:NO];
            completion(driver, nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETDriver];
        if (completion) {
            NSError *raError = [error filteredErrorAtReponse:operation.response];
            completion(nil, raError);
        }
    }];
}

+ (void)getSelectedCarWithCompletion:(void (^)(Car *, NSError *))completion {
    [self getDriversCurrentWithCompletion:^(RADriverDataModel *driver, NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSArray<Car *>*selectedCars = [driver.cars filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Car * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return evaluatedObject.isSelected;
            }]];
            if (selectedCars.count > 0) {
                Car *selectedCar = selectedCars.firstObject;
                if (completion) {
                    completion(selectedCar, nil);
                }
            } else {
                NSError *noCarSelectedError = [NSError errorWithDomain:@"GETDriverCarsNoneSelected" code:-194 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: @"None of your cars is selected. Please go to Settings -> My Cars to select Car"}];
                [ErrorReporter recordError:noCarSelectedError withDomainName:GETDriverCarsNoneSelected];
                if (completion) {
                    completion(nil,noCarSelectedError);
                }
            }
        }
    }];
}

#pragma mark - Statistics

+ (void)getStatisticForDriverWithId:(NSString *)driverId completion:(DriverStatisticBlock)completion {
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    NSString *path = [NSString stringWithFormat:kPathDriverStats, driverId];
    [httpClient getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSArray<RADriverStatDataModel *> *driverStats = [MTLJSONAdapter modelsOfClass:[RADriverStatDataModel class] fromJSONArray:responseObject error:&error];
        if (completion) {
            completion(driverStats, error);
        }
        
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETDriver];
        if (completion) {
            NSError *raError = [error filteredErrorAtReponse:operation.response];
            completion(nil, raError);
        }
    }];
}

#pragma mark - Earnings
+ (void)getRideFaresForDriverWithId:(NSNumber *)driverID withParams:(NSDictionary *)params andCompletion:(void (^)(NSDictionary *, NSError *))handler {
    NSString *path = [NSString stringWithFormat:kPathDriversRides, driverID.stringValue];

    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager.HTTPClient setParameterEncoding: AFRKJSONParameterEncoding];
    [objectManager.HTTPClient getPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary*)responseObject;
            if (handler) {
                handler(dict,nil);
            }
        } else {
            NSError *err = [NSError errorWithDomain:@"com.rideaustin.ridesError" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey:@"Parsing error"}];
            [ErrorReporter recordError:err withDomainName:GETEarningsRidesInvalidResponse];
            if (handler) {
                handler(nil,err);
            }
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETEarningsRides];
        if (handler) {
            handler(nil,error);
        }
    }];
}

+ (void)getOnlineTimeForDriver:(NSNumber *)driverID withParams:(NSDictionary *)params andCompletion:(void (^)(NSDictionary *, NSError *))handler {
    NSString * path = [NSString stringWithFormat:kPathDriversOnline, driverID.stringValue];
    DBLog(@"PATH: %@", path);
    DBLog(@"PARAMS: %@", params);
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient.copy;
    [client setParameterEncoding: AFRKJSONParameterEncoding];
    [client getPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary*)responseObject;
            if (handler) {
                handler(dict,nil);
            }
        } else {
            NSError *err = [NSError errorWithDomain:@"com.rideaustin.ridesError" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey:@"Parsing error"}];
            [ErrorReporter recordError:err withDomainName:GETEarningsTimeOnlineInvalidResponse];
            if (handler) {
                handler(nil,err);
            }
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETEarningsTimeOnline];
        if (handler) {
            handler(nil,error);
        }
    }];
}

#pragma mark - Refer a driver

/**
 API Callback to POST and send the Refer A Friend by Email
 @param Email - Email recipient to send the refer a friend Email
 @param completion - The completion handler
 */
+ (void)postReferAFriendByEmail:(NSString *)email withCompletion:(void (^)(id, NSError *))completion {
    NSString *driverId = [self driverId];
    NSParameterAssert(driverId);
    NSParameterAssert(email);
    NSString * path = [NSString stringWithFormat:kPathDriversReferByEmail, driverId];
    DBLog(@"PATH: %@", path);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:email forKey:@"email"];
    [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFRKFormURLParameterEncoding;
    [[RKObjectManager sharedManager].HTTPClient postPath:path parameters:parameters success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:POSTReferAFriend];
        completion(nil, error);
    }];
}

/**
 API Callback to POST and send the Refer A Friend by SMS
 @param Phone - Phone recipient to send the refer a friend SMS
 @param completion - The completion handler
 */
+ (void)postReferAFriendBySMS:(NSString *)phone withCompletion:(void (^)(id, NSError *))completion {
    NSString *driverId = [self driverId];
    NSParameterAssert(driverId);
    NSParameterAssert(phone);
    
    NSString * path = [NSString stringWithFormat:kPathDriversReferBySMS, driverId];
    DBLog(@"PATH: %@", path);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:phone forKey:@"phoneNumber"];
    [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFRKFormURLParameterEncoding;
    [[RKObjectManager sharedManager].HTTPClient postPath:path parameters:parameters success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:POSTReferAFriend];
        completion(nil, error);
    }];
}

#pragma mark - DriversDocuments

+ (void)postDocumentPhoto:(UIImage*)image withPhotoType:(NSString*)photoType expirationDate:(NSDate *)expirationDate andCarId:(NSString* __nullable)carId atCityId:(NSNumber * _Nullable)cityId completion:(DocumentCompletion)completion {
    NSString *driverId = [self driverId];
    NSParameterAssert(driverId);
    NSParameterAssert(image);
    
    NSData *documentData = [image compressToMaxSize:300000];
    if (documentData) {
        NSString * path = [NSString stringWithFormat:kPathDriversDocuments, driverId];
        
        AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient.copy;
        [client setParameterEncoding: AFRKFormURLParameterEncoding];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:photoType forKey:@"driverPhotoType"];
        params[@"cityId"]   = cityId;
        params[@"carId"]    = carId;
        if (expirationDate) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            params[@"validityDate"] = [dateFormatter stringFromDate:expirationDate];
        }
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:path parameters:params  constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
            [formData appendPartWithFileData: documentData
                                        name: @"fileData"
                                    fileName: @"fileData.png"
                                    mimeType: @"image/png"];
        }];
        
        AFRKHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
            if (completion) {
                completion(nil);
            }
        } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
            [ErrorReporter recordError:error withDomainName:POSTImageInvalidImage];
            if (completion) {
                completion(error);
            }
        }];
        [client enqueueHTTPRequestOperation:operation];
    } else {
        NSError *error = [NSError errorWithDomain:@"POSTImageInvalidImage" code:-1 userInfo:nil];
        [ErrorReporter recordError:error withDomainName:POSTImageInvalidImage];
        if (completion) {
            completion(error);
        }
    }
    
}

/**
 * @brief this will get list of documents, the one with the highest id is the latest
 */
+ (void)getDocumentWithPhotoType:(NSString *)photoType completion:(void (^)(RADocument *, NSError *))completion {
    NSString *driverId = [self driverId];
    NSParameterAssert(driverId);
    NSParameterAssert(photoType);
    NSString *path = [NSString stringWithFormat:kPathDriversDocuments, driverId];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"documentType"] = photoType;
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    [client getPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSArray *documents = [MTLJSONAdapter modelsOfClass:[RADocument class] fromJSONArray:responseObject error:&error];
        [ErrorReporter recordError:error withDomainName:GETDriverFile];
        RADocument *latestDoc = documents.lastObject;
        for (RADocument *doc in documents) {
            if (doc.documentID.doubleValue > latestDoc.documentID.doubleValue) {
                latestDoc = doc;
            }
        }
        completion(latestDoc,error);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETDriverFile];
        completion(nil,error);
    }];
}
+ (void)getDocumentWithPhotoType:(NSString *)photoType withCarId:(NSString *)carId completion:(void (^)(RADocument *, NSError *))completion {
    NSString *driverId = [self driverId];
    NSParameterAssert(driverId);
    NSParameterAssert(photoType);
    NSParameterAssert(carId);
    NSString *path = [NSString stringWithFormat:kPathDriversDocumentsCars,driverId,carId];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"documentType"] = photoType;
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    [client getPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSArray *documents = [MTLJSONAdapter modelsOfClass:[RADocument class] fromJSONArray:responseObject error:&error];
        [ErrorReporter recordError:error withDomainName:GETDriverCarFile];
        RADocument *document = documents.lastObject;
        completion(document,error);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETDriverCarFile];
        completion(nil,error);
    }];
    
}

+ (void)updateDocument:(RADocument *)document withCompletion:(void (^)(NSError *))completion {
    
    NSString *path = [NSString stringWithFormat:kPathDriversDocuments, document.documentID];
    
    NSError *mError = nil;
    NSDictionary *json = [MTLJSONAdapter JSONDictionaryFromModel:document error:&mError];
    [ErrorReporter recordError:mError withDomainName:PUTDocuments];
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    client.parameterEncoding = AFRKJSONParameterEncoding;
    [client putPath:path parameters:json success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:PUTDocuments];
        completion(error);
    }];
}

#pragma mark - Car types
+ (void)getCarTypesForCity:(NSNumber *)cityID withCompletion:(void (^)(NSArray<RACarCategoryDataModel *> *, NSError *))completion {
    NSString *path = kPathDriversCarTypes;
    NSDictionary *params = @{@"city":cityID};
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    client.parameterEncoding = AFRKFormURLParameterEncoding;
    [client getPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSArray <RACarCategoryDataModel *> *carTypes = [RAJSONAdapter modelsOfClass:RACarCategoryDataModel.class fromJSONArray:responseObject isNullable:NO];
        if (completion) {
            completion(carTypes, nil);
        }
        
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETCarCategories];
        if (completion) {
            completion(nil, [error filteredErrorAtReponse:operation.response]);
        }
    }];
}

#pragma mark - Driver types
+ (void)getDriverTypesForCity:(NSNumber *)cityID withCompletion:(void (^)(NSArray<RADriverType *> *, NSError *))completion {
    NSString *path = kPathDriverTypes;
    NSDictionary *params = @{@"city":cityID};
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    client.parameterEncoding = AFRKFormURLParameterEncoding;
    [client getPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSArray <RADriverType *> *driverTypes = [RAJSONAdapter modelsOfClass:RADriverType.class fromJSONArray:responseObject isNullable:YES];
        if (completion) {
            completion(driverTypes, nil);
        }
        
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETDriverTypes];
        if (completion) {
            completion(nil, [error filteredErrorAtReponse:operation.response]);
        }
    }];
}

#pragma mark - Direct Connect
+ (void)getNewDriverConnectIdWithCompletion:(void(^)(NSString *driverConnectId, NSError *error))completion {
    NSString *path = [NSString stringWithFormat:kPathNewDriverConnectId, [self driverId]];
    [[RKObjectManager sharedManager].HTTPClient getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSString *directConnectId = [responseObject objectForKey:@"directConnectId"];
        [RASessionManager shared].currentSession.driver.directConnectId = directConnectId;
        if (completion) {
            completion(directConnectId, nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

#pragma mark - Helper
+ (NSString *)driverId {
    return [RASessionManager shared].currentSession.driver.modelID.stringValue;
}

+ (NSNumber *)cityId {
    return [RASessionManager shared].currentSession.driver.cityId;
}
@end
