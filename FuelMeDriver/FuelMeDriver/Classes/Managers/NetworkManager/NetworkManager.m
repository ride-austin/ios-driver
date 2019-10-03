//
//  NetworkManager.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 7/25/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import "NetworkManager.h"

#import "AppDelegate+Reskit.h"
#import "CLLocation+validation.h"
#import "ConfigurationManager.h"
#import "ErrorReporter.h"
#import "NSData+Base64.h"
#import "NSDate+Utils.h"
#import "NSError+ErrorFactory.h"
#import "NSString+CityID.h"
#import "PersistenceManager.h"
#import "UIImage+Ride.h"
#import "RAEnvironmentManager.h"

#import <SDWebImage/SDWebImagePrefetcher.h>

NSString *const PromoCodeResourcePath = @"promocodes";

NSString *const BatchLocationsUpdatePath= @"trackers";

NSString *const GetRideMapURLPath = @"rides/%@/map";
NSString *const kCarPhotosPath = @"carphotos/car/%@";
NSString *const kCarPhotoDeletePath = @"carphotos/%@";
NSString *const GetAllCarsPath = @"drivers/%@/allCars";
NSString *const kSelectCarPath = @"drivers/selected";

NSString *const kDriverUpdateCar = @"drivers/%@/cars/%@";

NSString *const kPathDriverAcceptTerms = @"/rest/drivers/terms/%@";

@interface NetworkManager()

@property (nonatomic, strong) NSOperationQueue *serialQueue;

@end

@implementation NetworkManager

- (id) init {
    self = [super init];
    if (self) {
        self.serialQueue = [[NSOperationQueue alloc] init];
        [self.serialQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

+ (NetworkManager*)sharedInstance {
    static NetworkManager *networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[self alloc]init];
    });
    return networkManager;
}

- (void)postPath:(NSString*)path params:(NSDictionary*)params completeBlock:(CompleteBlock)completeBlock {
    path = [self fixPathForServerWithSubdomain:path];
    [[RKObjectManager sharedManager].HTTPClient setParameterEncoding: AFRKFormURLParameterEncoding];
    [[RKObjectManager sharedManager].HTTPClient postPath:path
                                              parameters:params
                                                 success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
                                                     NSString *uuid = nil;
                                                     NSString *location = [[operation.response allHeaderFields] objectForKey:@"location"];
                                                     if (location) {
                                                         uuid = [[location componentsSeparatedByString:@"/"] lastObject];
                                                     }
                                                     
                                                     if (completeBlock) {
                                                         completeBlock(uuid, operation.response.statusCode, nil);
                                                     }
                                                 }
                                                 failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
                                                     NSError *raError = [error filteredErrorAtReponse:operation.response];
                                                     if (completeBlock) {
                                                         completeBlock(nil, operation.response.statusCode, raError);
                                                     }
                                                 }];
}

- (void)putPath:(NSString*)path params:(NSDictionary*)params completeBlock:(CompleteBlock)completeBlock {
    path = [self fixPathForServerWithSubdomain:path];
    [[RKObjectManager sharedManager].HTTPClient setParameterEncoding: AFRKFormURLParameterEncoding];
    [[RKObjectManager sharedManager].HTTPClient putPath:path
                                             parameters:params
                                                success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
                                                    if (completeBlock) {
                                                        completeBlock(nil, operation.response.statusCode, nil);
                                                    }
                                                 }
                                                 failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
                                                     NSError *raError = [error filteredErrorAtReponse:operation.response];
                                                     if (completeBlock) {
                                                         completeBlock(nil, operation.response.statusCode, raError);
                                                     }
                                                 }];
}

- (void)deletePath:(NSString*)path params:(NSDictionary*)params completeBlock:(CompleteBlock)completeBlock {
    path = [self fixPathForServerWithSubdomain:path];
    [[RKObjectManager sharedManager].HTTPClient setParameterEncoding: AFRKFormURLParameterEncoding];
    [[RKObjectManager sharedManager].HTTPClient deletePath:path
                                             parameters:params
                                                success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
                                                    if (completeBlock) {
                                                        completeBlock(nil, operation.response.statusCode, nil);
                                                    }
                                                }
                                                failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
                                                    NSError *raError = [error filteredErrorAtReponse:operation.response];
                                                    if (completeBlock) {
                                                        completeBlock(nil, operation.response.statusCode, raError);
                                                    }
                                                }];
}

/**
 * fix the path for postPath and putPath to make them work with the server having a subdomain, like "http://localhost:8080/ride-austin/rest"
 */
- (NSString*)fixPathForServerWithSubdomain:(NSString*)path {
    if ([path hasPrefix:@"/rest"]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"https?://.+?(/.+?)/rest"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:NULL];
        NSString *server = [[RAEnvironmentManager sharedManager] serverUrl];
        NSArray *arr = [regex matchesInString:server options:0 range:NSMakeRange(0, [server length])];
        if (arr != nil && [arr count] > 0) {
            NSTextCheckingResult *match = [arr firstObject];
            NSRange matchRange = [match rangeAtIndex:1];
            NSString *subdomain = [server substringWithRange:matchRange];
            path = [NSString stringWithFormat:@"%@%@", subdomain, path];
        }
    }
    return path;
}

- (BOOL)isNetworkReachable {
    AFRKNetworkReachabilityStatus status = [[[RKObjectManager sharedManager] HTTPClient] networkReachabilityStatus];
    if (status == AFRKNetworkReachabilityStatusUnknown || status == AFRKNetworkReachabilityStatusNotReachable) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Queues

- (void)getPositionForDriver:(NSNumber *)driverId withCompletion:(void (^)(NSDictionary *, NSError *))completionHandler {
    NSParameterAssert(driverId);
    NSString *path = [NSString stringWithFormat:kPathDriversQueue,driverId.stringValue];
    path = [path pathWithCityAppendType:AppendAsFirstParameter];
    [[[RKObjectManager sharedManager] HTTPClient] getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            completionHandler(responseObject, nil);
        } else {
            NSError *error = [ErrorReporter recordErrorDomainName:GETQueuePositionInvalidResponse withInvalidResponse:responseObject];
            completionHandler(nil,error);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETQueuePosition];
        completionHandler(nil, error);
    }];
}

#pragma mark - Surge Pricing

#define PAGESIZE @10000

- (void)getSurgeAreas:(void (^)(NSArray<SurgeArea*>*areasArray, NSError *error))completionHandler{
    NSDictionary *params = @{ @"pageSize" : PAGESIZE,
                              @"cityId"   : [ConfigurationManager shared].global.currentCity.cityID };
    
    [[RKObjectManager sharedManager].HTTPClient getPath:kPathSurgeAreas parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *contentArray = responseObject[@"content"];
            if ([contentArray isKindOfClass:[NSArray class]]) {
                
                NSError *error;
                NSArray *surgeAreas = [MTLJSONAdapter modelsOfClass:[SurgeArea class] fromJSONArray:contentArray error:&error];
                
                if (!error) {
                    completionHandler(surgeAreas, nil);
                    return;
                }
            }
        }
        
        NSError *err = [NSError errorWithDomain:@"getSurgeAreas-Invalid-Response" code:-1 userInfo:nil];
        [ErrorReporter recordError:err withDomainName:GETSurgePricingInvalidResponse];
        completionHandler(nil,err);
        
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETSurgePricing];
        completionHandler(nil, error);
    }];
}

#pragma mark - Driver Photo Upload Image
/**
 API Callback to POST and upload Driver Photo
 @param params - NSDictionary of parameters
 @param driverID - Driver Identification number
 @param completionBlock - The completion handler
 */
- (void)postDriverPhotoWithParams:(NSDictionary *)params
                      andDriverID:(NSString *)driverID
              uploadCompleteBlock:(UploadDataCompleteBlock)completionBlock {
    
    NSData *photoData = [params objectForKey:@"photoData"];

    //check photo data is valid
    if (photoData) {
        
        NSString * path = [NSString stringWithFormat:kPathDriversPhoto, driverID];
        DBLog(@"PATH: %@", path);
        
        AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient.copy;
        [client setParameterEncoding: AFRKFormURLParameterEncoding];
        
        NSMutableURLRequest *request = [[RKObjectManager sharedManager].HTTPClient multipartFormRequestWithMethod:@"POST" path:path parameters: nil constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
            [formData appendPartWithFileData: photoData
                                        name: @"photoData"
                                    fileName: @"photo.png"
                                    mimeType: @"image/png"];
        }];
        
        DBLog(@"Photo Data Lenght: %lu", (unsigned long)photoData.length);
        
        RKObjectManager *manager = [RKObjectManager sharedManager];
        AFRKHTTPRequestOperation *operation = [manager.HTTPClient HTTPRequestOperationWithRequest:request success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
            
            //parse photoURL            
            NSString *photoUrl = [responseObject objectForKey:@"photoUrl"];
            
            if (photoUrl) {
                NSString *photoName = [[photoUrl componentsSeparatedByString:@"/"] lastObject];
                NSString *directory = RKApplicationDataDirectory();
                NSString *filePath = [directory stringByAppendingPathComponent:photoName];
                [photoData writeToFile:filePath atomically:YES];
            }
            
            if (completionBlock) {
                completionBlock(photoUrl, nil);
            }
        } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
            DBLog(@"Update Photo Error: %@",error);
            if (completionBlock) {
                [ErrorReporter recordError:error withDomainName:POSTImage];
                completionBlock(nil, error);
            }
        }];
        
        [self.serialQueue addOperation:operation];
    } else {
        NSError *err = [NSError errorWithDomain:@"POSTImageInvalidImage" code:-1 userInfo:nil];
        DBLog(@"Update Photo Error: %@",err);
        [ErrorReporter recordError:err withDomainName:POSTImageInvalidImage];
        if (completionBlock) {
            completionBlock(nil, err);
        }
    }
}

#pragma mark- Car Photos

- (void)getCarPhotosWithCarID:(NSString*)carID andCompletionBlock:(CarPhotoCompletionBlock)block {
    NSString *path = [NSString stringWithFormat:kCarPhotosPath, carID];
    DBLog(@"PATH: %@", path);
    
    [[[RKObjectManager sharedManager] HTTPClient] getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            block(responseObject, nil);
        } else {
            NSError *err = [NSError errorWithDomain:@"getCarPhotos-Invalid-Response" code:-1 userInfo:nil];
            [ErrorReporter recordError:err withDomainName:GETCarPhotos];
            block(nil,err);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETCarPhotos];
        DBLog(@"KKKKKKKKKKKKKKK");

        block(nil, error);
    }];
}

- (void)postCarPhotoWithParams:(NSDictionary *)params
                      andCarID:(NSString *)carID
                    andCarType:(NSString*)type
              uploadCompleteBlock:(UploadDataCompleteBlock)completionBlock {
    
    NSData *photoData = [params objectForKey:@"photoData"];
    
    //check photo data is valid
    if (photoData) {
        
        NSString * path = [NSString stringWithFormat:kCarPhotosPath, carID];
        DBLog(@"PATH: %@", path);
        
        NSDictionary *carPhotoTypeParameter = @{@"carPhotoType":type};
        
        AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient.copy;
        [client setParameterEncoding: AFRKFormURLParameterEncoding];
        
        NSMutableURLRequest *request = [[RKObjectManager sharedManager].HTTPClient multipartFormRequestWithMethod:@"POST" path:path parameters: carPhotoTypeParameter constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
            [formData appendPartWithFileData: photoData
                                        name: @"photo"
                                    fileName: @"photo.png"
                                    mimeType: @"image/png"];
        }];
        
        DBLog(@"Photo Data Lenght: %lu", (unsigned long)photoData.length);
        
        RKObjectManager *manager = [RKObjectManager sharedManager];
        AFRKHTTPRequestOperation *operation = [manager.HTTPClient HTTPRequestOperationWithRequest:request success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
            
            //parse photoURL
            NSString *photoUrl = [responseObject objectForKey:@"photoUrl"];
            
            if (photoUrl) {
                NSString *photoName = [[photoUrl componentsSeparatedByString:@"/"] lastObject];
                NSString *directory = RKApplicationDataDirectory();
                NSString *filePath = [directory stringByAppendingPathComponent:photoName];
                [photoData writeToFile:filePath atomically:YES];
            }
            
            if (completionBlock) {
                completionBlock(photoUrl, nil);
            }
        } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
            if (completionBlock) {
                [ErrorReporter recordError:error withDomainName:POSTImage];
                completionBlock(nil, error);
            }
        }];
        
        [self.serialQueue addOperation:operation];
    } else {
        NSError *err = [NSError errorWithDomain:@"POSTImageInvalidImage" code:-1 userInfo:nil];
        [ErrorReporter recordError:err withDomainName:POSTImageInvalidImage];
        if (completionBlock) {
            completionBlock(nil, err);
        }
    }
}

- (void)deleteCarPhotoWithCarPhotoID:(NSString*)carPhotoID andCompletionBlock:(CarPhotoDeleteCompletionBlock)block {
    NSString * path = [NSString stringWithFormat:kCarPhotoDeletePath, carPhotoID];
    DBLog(@"PATH: %@", path);
    
    [[RKObjectManager sharedManager].HTTPClient deletePath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
       if (block) {
           block(responseObject,nil);
       }
   } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
       NSError *raError = [error filteredErrorAtReponse:operation.response];
       [ErrorReporter recordError:error withDomainName:DELETECarPhoto];
       if (block) {
           block(nil, raError);
       }
   }];
}

#pragma mark- Cars

- (void)getCarsOfDriverWithID:(NSString*)driverID andCompletionBlock:(CarsCompletionBlock)block {
    NSString * path = [NSString stringWithFormat:GetAllCarsPath, driverID];
    DBLog(@"PATH: %@", path);
    
    [[[RKObjectManager sharedManager] HTTPClient] getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSArray <Car*> *cars = [MTLJSONAdapter modelsOfClass:[Car class] fromJSONArray:responseObject error:&error];
        [ErrorReporter recordError:error withDomainName:GETAllCarsInvalidResponse];
        block(cars, error);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETAllCars];
        block(nil, error);
    }];
}

- (void) addCarInformationWithPath:(NSString*)path carData:(NSData * )carData photoData:(NSData*)photoData completeBlock:(void (^)(Car *car, NSError *error))block {
    
    NSMutableURLRequest *request = [[RKObjectManager sharedManager].HTTPClient multipartFormRequestWithMethod:@"POST" path: path parameters: nil constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
        [formData appendPartWithFileData: carData
                                    name:@"car"
                                fileName:@"car.json"
                                mimeType: RKMIMETypeJSON];
        if ([photoData isKindOfClass:[NSData class]]) {
            [formData appendPartWithFileData: photoData
                                        name: @"photo"
                                    fileName: @"car.png"
                                    mimeType: @"image/png"];
        }
    }];
    
    RKObjectManager *manager = [RKObjectManager sharedManager];
    AFRKHTTPRequestOperation *operation = [manager.HTTPClient HTTPRequestOperationWithRequest:request success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        Car *car = [MTLJSONAdapter modelOfClass:[Car class] fromJSONDictionary:(NSDictionary*)responseObject error:&error];
        [ErrorReporter recordError:error withDomainName:POSTCarInformation];
        block(car,error);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        CLSLog(@"addCarInformationWithPath carData:%lu", (unsigned long)carData.length);
        [ErrorReporter recordError:error withDomainName:POSTCarInformation];
        block(nil,error);
    }];
    
    [self.serialQueue addOperation:operation];
}

- (void)selectCarWithCarID:(NSString*)carID andDriverID:(NSString*)driverID andCompletionBlock:(void (^)(id object, NSError *error))block {
    NSString *path=[NSString stringWithFormat:@"%@?driverId=%@&carId=%@", kSelectCarPath, driverID, carID];
    [[[RKObjectManager sharedManager] HTTPClient] putPath:path
                                               parameters:nil
                                                  success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
                                                      block(responseObject,nil);
                                                  }
                                                  failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
                                                      [ErrorReporter recordError:error withDomainName:PUTSelectCar];
                                                      block(nil,error);
                                                  }];


}

- (void)updateCar:(Car*)car withDriverID:(NSString*)driverID completion:(void(^)(NSError *error))completion {
    NSError *error = nil;
    NSDictionary *carDict = [MTLJSONAdapter JSONDictionaryFromModel:car error:&error];
    if (error) {
        [ErrorReporter recordError:error withDomainName:PUTUpdateCar];
        completion(error);
        return;
    }
    
    NSData *carData = [NSJSONSerialization dataWithJSONObject:carDict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        [ErrorReporter recordError:error withDomainName:PUTUpdateCar];
        completion(error);
        return;
    }
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient.copy;
    [client setParameterEncoding: AFRKFormURLParameterEncoding];
    
    NSString *path = [NSString stringWithFormat:kDriverUpdateCar,driverID, car.modelID.stringValue];
    NSMutableURLRequest *request = [client requestWithMethod:@"PUT" path:path parameters:nil];
    [request setHTTPBody:carData];
    
    AFRKHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:PUTUpdateCar];
        if (completion) {
            completion(error);
        }
    }];
    
    [self.serialQueue addOperation:operation];
}

#pragma mark - City Detail

+ (void)getCityDetailWithID:(NSNumber *)cityID withCompletion:(void (^)(RACityDetail *cityDetail, NSError *error))handler {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    NSString *attribute = @"driverRegistration";
    params[@"cityId"] = cityID;
    params[@"configAttributes"] = attribute;
    
    NSString *path = @"configs/rider/global";
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    [client getPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[attribute]) {
            NSDictionary *cityDetailDict = responseObject[attribute];
            NSError *error = nil;
            RACityDetail *cityDetail = [MTLJSONAdapter modelOfClass:RACityDetail.class fromJSONDictionary:cityDetailDict error:&error];
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:cityDetail.urls];
            [ErrorReporter recordError:error withDomainName:GETCityDetail];
            if (handler) {
                handler(cityDetail, error);
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:@"com.rideaustin.citydetail.parse.error" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: @"Bad city detail json", NSLocalizedFailureReasonErrorKey: @"Bad city detail json", NSLocalizedDescriptionKey: @"Bad city detail json"}];
            [ErrorReporter recordError:error withDomainName:GETCityDetail];
            if (handler) {
                handler(nil, error);
            }
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETCityDetail];
        DBLog(@"MMMMMMMMMMM");

        if (handler) {
            handler(nil, error);
        }
    }];
}


#pragma mark - Push Notifications Device Token

+ (void)registerDeviceToken:(NSString *)token andDeviceID:(NSString *)deviceID {
    if (token) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"value"]        = token;
        params[@"type"]         = @"APPLE";
        params[@"avatarType"]   = @"DRIVER";
        params[@"deviceId"]     = deviceID;
        
        //FIX RA-7810 Parameter Encoding
        [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFRKFormURLParameterEncoding;
        [[NetworkManager sharedInstance] postPath:kPathTokens params:params completeBlock:^(NSString *resourceId, NSInteger statusCode, NSError *error) {
            if (error) {
                [PersistenceManager removeCachedDeviceToken];
                DBLog(@"Failure registering token: %@", error.localizedRecoverySuggestion);
            } else {
                [PersistenceManager saveRegisteredDeviceToken:token];
                DBLog(@"Success registering token: %@", token);
            }
        }];
    }
}

#pragma mark - Get Driver Terms & Condition

+ (void)getDriverTermsAtURL:(NSURL *)termsURL WithCompletion:(void (^)(NSString *, NSError *))completion {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:termsURL];
    [request setHTTPMethod:@"GET"];
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    AFRKHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSString *terms = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            completion(terms, nil);
        } else {
            NSError *err = [ErrorReporter recordErrorDomainName:GETDriverTerms withInvalidResponse:responseObject];
            completion(nil, err);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:GETDriverTerms];
        completion(nil,error);
    }];
    
    [client enqueueHTTPRequestOperation:operation];
}

+ (void)acceptTermsWithId:(NSString*)termId withCompletion:(void(^)(NSError *))completion {
    NSString *path = [NSString stringWithFormat:kPathDriverAcceptTerms,termId];
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    [client putPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:PUTAcceptDriverTerms];
        if (completion) {
            completion(error);
        }
    }];
}

@end
