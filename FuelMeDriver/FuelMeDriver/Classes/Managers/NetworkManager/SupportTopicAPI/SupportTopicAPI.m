//
//  SupportTopicAPI.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/26/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "SupportTopicAPI.h"

#import "LIOptionDataModel.h"

@implementation SupportTopicAPI

+ (void)getSupportTopicListWithCompletion:(SupportTopicBlock)handler {
    [[RKObjectManager sharedManager].HTTPClient getPath:kPathSupportTopic parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSError *error;
            NSArray *supportTopics = [MTLJSONAdapter modelsOfClass:[RASupportTopic class] fromJSONArray:(NSArray*)responseObject error:&error];
            handler(supportTopics, error);
        } else {
            NSError *error = [NSError errorWithDomain:@"com.driver.trip.support.topic.parse.error" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: @"Bad Support Topic json", NSLocalizedFailureReasonErrorKey: @"Bad Support Topic json", NSLocalizedDescriptionKey: @"Bad Support Topic json"}];
            if (handler) {
                handler(nil, error);
            }
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }];
}

+ (void)getTopicsWithParentId:(NSNumber* _Nonnull)parentTopicId withCompletion:(SupportTopicBlock)handler {
    NSString *path = [NSString stringWithFormat:kPathSupportTopicChildren,parentTopicId];
    [[RKObjectManager sharedManager].HTTPClient getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSError *error;
            NSArray *supportTopics = [MTLJSONAdapter modelsOfClass:[RASupportTopic class] fromJSONArray:(NSArray*)responseObject error:&error];
            handler(supportTopics, error);
        } else {
            NSError *error = [NSError errorWithDomain:@"com.driver.trip.support.topic.parse.error" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: @"Bad Support Topic json", NSLocalizedFailureReasonErrorKey: @"Bad Support Topic json", NSLocalizedDescriptionKey: @"Bad Support Topic json"}];
            if (handler) {
                handler(nil, error);
            }
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        if (handler) {
            handler(nil,error);
        }
    }];
}

+ (void)getFormForTopic:(RASupportTopic *)topic withCompletion:(void(^)(LIOptionDataModel *, NSError *))completion {
    NSString *path = [NSString stringWithFormat:kPathSupportTopicForm, topic.modelID];
    [[RKObjectManager sharedManager].HTTPClient getPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id response) {
        NSError *error;
        LIOptionDataModel *form = [MTLJSONAdapter modelOfClass:[LIOptionDataModel class] fromJSONDictionary:response error:&error];
        completion(form, error);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

+ (void)postSupportMessage:(NSString* _Nonnull)comment supportTopic:(RASupportTopic* _Nonnull)supportTopic rideId:(NSNumber* _Nonnull)rideId withCompletion:(SupportTopicPostMessageBlock _Nonnull)handler {
    NSDictionary *params = @{ @"rideId"   : rideId,
                              @"comments" : comment,
                              @"topicId"  : supportTopic.modelID };
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    client.parameterEncoding = AFRKJSONParameterEncoding;
    [client postPath:kPathSupportTopicMessage parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (handler) {
            handler(nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        if (handler) {
            handler(error);
        }
    }];
}

+ (void)postSupportMessage:(NSString *)message rideID:(NSString *)rideID withCompletion:(void (^)(id, NSError *))completion {
    
    NSNumber *cityId = [RASessionManager shared].currentSession.driver.cityId;
    NSString *path = @"support";
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"message"] = message;
    parameters[@"rideId"]  = rideID;
    parameters[@"cityId"]  = cityId;
    [RKObjectManager sharedManager].HTTPClient.parameterEncoding = AFRKFormURLParameterEncoding;
    [[RKObjectManager sharedManager].HTTPClient postPath:path
                                              parameters:parameters
                                                 success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
                                                     completion(responseObject, nil);
                                                 }
                                                 failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
                                                     [ErrorReporter recordError:error withDomainName:POSTSupport];
                                                     completion(nil, error);
                                                 }];
    
}

#pragma mark - Rider Lost Items

+ (void)postLostAndFoundLostParameters:(NSDictionary *)params withCompletion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion {
    NSString *path = kPathLostAndFoundLost;
    [[RKObjectManager sharedManager].HTTPClient postPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id response) {
        DBLog(@"%@: %@",path, response);
        completion(response[@"message"], nil);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

+ (void)postLostAndFoundContactParameters:(NSDictionary *)params withCompletion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion {
    NSString *path = kPathLostAndFoundContact;
    [[RKObjectManager sharedManager].HTTPClient postPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id response) {
        DBLog(@"%@: %@",path, response);
        completion(response[@"message"], nil);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

#pragma mark - Driver Lost Items

+ (void)postLostAndFoundFoundParameters:(NSDictionary *)params andImages:(NSDictionary<NSString *, NSData *> *)images withCompletion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion {
    NSString *path = kPathLostAndFoundFound;
    
    NSError *error;
    NSData *itemData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (error) {
        completion(nil, error);
        return;
    }
    NSMutableURLRequest *request = [[RKObjectManager sharedManager].HTTPClient multipartFormRequestWithMethod:@"POST" path:path parameters: nil constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
        [formData appendPartWithFileData:itemData name:@"item" fileName:@"item.json" mimeType:RKMIMETypeJSON];
        for (NSString *imageVariable in images.allKeys) {
            NSString *name = [NSString stringWithFormat:@"%@.png", imageVariable];
            [formData appendPartWithFileData:images[imageVariable]
                                        name:imageVariable
                                    fileName:name
                                    mimeType:@"image/png"];
        }
    }];
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    AFRKHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFRKHTTPRequestOperation *operation, id response) {
        DBLog(@"%@: %@",path, response);
        completion(response[@"message"], nil);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
    [client enqueueHTTPRequestOperation:operation];
}

@end
