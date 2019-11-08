//
//  RARideAPI.m
//  RideDriver
//
//  Created by Roberto Abreu on 6/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARideAPI.h"

#import "ErrorReporter.h"
#import "NSString+CityID.h"

#import <Mantle/Mantle.h>

@implementation RARideAPI

+ (void)getCurrentRideWithCompletion:(RideCompletionBlock)completion {
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient getPath:kPathCurrentRide parameters:@{@"avatarType":@"DRIVER"} success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        RARideDataModel *rideDataModel = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:responseObject error:&error];
        if (error) {
            CLSLog(@"InvalidJSONRidesCurrent %@", error);
            BFLogErr(@"InvalidJSONRidesCurrent %@", error);
            [ErrorReporter recordErrorDomainName:InvalidJSONRidesCurrent withUserInfo:responseObject];
        }
        
        if (completion) {
            completion(rideDataModel, error);
        }
        
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
}

+ (void)postEvents:(NSDictionary *)events withCompletion:(void(^)(NSError *))completion {
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient.copy;
    [client setParameterEncoding:AFRKJSONParameterEncoding];
    [client postPath:kPathRidesEvents parameters:events success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        BFLog(@"Post events success. events: %@", [events valueForKey:@"eventType"]);
        completion(nil);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        BFLogWarn(@"Post events success. events: %@", [events valueForKey:@"eventType"]);
        [ErrorReporter recordError:error withDomainName:POSTRidesEvents];
        completion(error);
    }];
}



+ (void)ackReceivedRideWithId:(NSNumber *)rideId completion:(StatusCompletionBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathAckReceivedRide,rideId];
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient postPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(operation.response.statusCode, nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:POSTRidesReceived];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(operation.response.statusCode, raError);
        }
    }];
}

+ (void)acceptRideWithId:(NSNumber *)rideId andCompletion:(void(^)(NSError *))completion {
    NSString *path = [[NSString stringWithFormat:kPathAcceptRide,rideId] pathWithCityAppendType:AppendAsFirstParameter];
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient postPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        BFLog(@"RideRequest attemptToAcceptRide success");
        if (completion) {
            completion(nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        BFLogErr(@"RideRequest attemptToAcceptRide with error: %@",error);
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(raError);
        }
    }];
}

+ (void)startRideWithId:(NSString *)rideId latitude:(double)lat longitude:(double)lng andCompletion:(StatusCompletionBlock)completion {
    NSString *path = [[NSString stringWithFormat:kPathStartRide,rideId] pathWithCityAppendType:AppendAsFirstParameter];
    NSDictionary *params = @{@"endLocationLat"  : @(lat),
                            @"endLocationLong" : @(lng)};
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient postPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        BFLog(@"Driver Start Ride %@ success", rideId);
        if (completion) {
            completion(operation.response.statusCode, nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        BFLogErr(@"Driver Start Ride %@ with error : %@",rideId, error);
        [ErrorReporter recordError:error withDomainName:POSTStartRide];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(operation.response.statusCode, raError);
        }
    }];
}

+ (void)reachedRideWithId:(NSString *)rideId andCompletion:(StatusCompletionBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathReachedRide,rideId];
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient postPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        BFLog(@"Driver Arrived for ride with id : %@",rideId);
        if (completion) {
            completion(operation.response.statusCode, nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        BFLogErr(@"DriverArrived for ride with id : %@ - failed with error : %@",rideId,error);
        [ErrorReporter recordError:error withDomainName:POSTStartRide];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(operation.response.statusCode, raError);
        }
    }];
}

+ (void)endRideWithId:(NSString *)rideId latitude:(double)lat longitude:(double)lng andCompletion:(RideCompletionBlock)completion {
    NSString *path = [[NSString stringWithFormat:kPathEndRide,rideId] pathWithCityAppendType:AppendAsFirstParameter];
    NSDictionary *params = @{@"endLocationLat"  : @(lat),
                             @"endLocationLong" : @(lng)};
    
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient postPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        BFLog(@"End Ride with Id %@",rideId);
        NSError *error;
        RARideDataModel *rideDataModel = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:responseObject error:&error];
        if (error) {
            CLSLog(@"InvalidJSONRidesEnd %@", error);
            BFLogErr(@"InvalidJSONRidesEnd %@", error);
            [ErrorReporter recordErrorDomainName:InvalidJSONRidesEnd withUserInfo:responseObject];
        }
        
        if (completion) {
            completion(rideDataModel, error);
        }
        
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        BFLogErr(@"End Ride with Id %@ -  error: %@",rideId,error);
        [ErrorReporter recordError:error withDomainName:POSTEndRide];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
}

+ (void)getRideWithId:(NSString*)rideId andCompletion:(RideCompletionBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathSpecificRide, rideId];
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient getPath:path parameters:@{@"avatarType":@"DRIVER"} success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        RARideDataModel *rideDataModel = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:responseObject error:&error];
        if (error) {
            CLSLog(@"InvalidJSONRidesSpecific %@", error);
            BFLogErr(@"InvalidJSONRidesSpecific %@", error);
            [ErrorReporter recordErrorDomainName:InvalidJSONRidesSpecific withUserInfo:responseObject];
        }
        
        if (completion) {
            completion(rideDataModel, error);
        }
        
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
}

+ (void)isRideActiveWithId:(NSString *)rideId andCompletion:(IsRideActiveBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathSpecificRide, rideId];
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient getPath:path parameters:@{@"avatarType":@"DRIVER"} success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        RARideDataModel *ride = [MTLJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:responseObject error:&error];
        if (error) {
            CLSLog(@"InvalidJSONRidesSpecific %@", error);
            BFLogErr(@"InvalidJSONRidesSpecific %@", error);
            [ErrorReporter recordErrorDomainName:InvalidJSONRidesSpecific withUserInfo:responseObject];
        }
        
        BOOL isRideActive = ride && ![ride.status isEqualToString:@"RIDER_CANCELLED"] && ![ride.status isEqualToString:@"DRIVER_CANCELLED"] &&
        ![ride.status isEqualToString:@"ADMIN_CANCELLED"] && ![ride.status isEqualToString:@"COMPLETED"];
        
        if (completion) {
            completion(isRideActive, error);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
}

+ (void)getMapURLForRideWithId:(NSString*)rideId andCompletion:(RideMapCompletionBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathRideMap,rideId];
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (!completion) {
            return;
        }
        
        NSDictionary *responseDict = (NSDictionary*)responseObject;
        if (responseDict && responseDict[@"url"]) {
            NSURL *mapURL = [NSURL URLWithString:responseDict[@"url"]];
            completion(mapURL, nil);
            return;
        }
        
        NSError *err = [NSError errorWithDomain:@"com.rideaustin.ridesError" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey:@"Parsing error"}];
        [ErrorReporter recordError:err withDomainName:GETRideMapURLInvalidResponse];
        completion(nil,err);
        
        
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
}

+ (void)declineRideWithId:(NSNumber *)rideId andCompletion:(APIErrorResponseBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathDeclineRide,rideId];
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient deletePath:path parameters:@{@"avatarType":@"DRIVER"} success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        DBLog(@"decline ride error: %@",error);
        [ErrorReporter recordError:error withDomainName:POSTDeclineRide];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(raError);
        }
    }];
}
+ (void)cancelRide:(NSString *)rideId withReason:(NSString *)reasonCode andComment:(NSString *)comment andCompletion:(APIErrorResponseBlock)completion {
    NSParameterAssert([rideId     isKindOfClass:NSString.class]);
    NSParameterAssert([reasonCode isKindOfClass:NSString.class] || !reasonCode);
    NSParameterAssert([comment    isKindOfClass:NSString.class] || !comment);
    
    NSString *path = [NSString stringWithFormat:kPathSpecificRide,rideId];
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"reason"]  = reasonCode;
    params[@"comment"] = comment;
    params[@"avatarType"] = @"DRIVER";
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient deletePath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(raError);
        }
    }];
}

+ (void)addRate:(float)rating toRideWithId:(NSString *)rideId andCompletionBlock:(APIErrorResponseBlock)completion {
    NSDictionary *params = @{@"rating":@(rating)};
    NSString *path = [NSString stringWithFormat:kPathRideRating,rideId];
    path = [NSString stringWithFormat:@"%@?%@",path,params.urlEncodedString]; //because PUT do not accept the params directly
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient putPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:PUTRateRide];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            if (raError.code == 400) {
                completion(nil);
            } else {
                completion(raError);
            }
        }
    }];
}

+ (void)requestUpgradeWithCategoryTarget:(NSString *)categoryTarget andCompletion:(RideUpgradeCompletionBlock)completion {
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient postPath:kPathRideUpgradeRequest parameters:@{@"target":categoryTarget} success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSString *message = responseObject[@"message"];
        if (completion) {
            completion(message,nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
}

+ (void)declineUpgradeWithCompletion:(RideUpgradeCompletionBlock)completion {
    AFRKHTTPClient *httpClient = [[RKObjectManager sharedManager].HTTPClient copy];
    [httpClient postPath:kPathRideUpgradeDecline parameters:@{@"avatarType":@"DRIVER"} success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSString *message = responseObject[@"message"];
        if (completion) {
            completion(message,nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
}

@end

@implementation RARideAPI (CancellationFeedback)

+ (void)getReasonsWithCompletion:(void (^)(NSArray<CFReasonDataModel *> *, NSError *))completion {
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient.copy;
    [client getPath:kPathRidesCancellation parameters:@{@"avatarType":@"DRIVER"} success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSArray<CFReasonDataModel *> *reasons = [MTLJSONAdapter modelsOfClass:CFReasonDataModel.class fromJSONArray:responseObject error:&error];
    
        if (completion) {
            completion(reasons, error);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
}

@end
