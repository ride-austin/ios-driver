//
//  RAUserAPI.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/3/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAUserAPI.h"

@implementation RAUserAPI

+ (void)checkAvailabilityOfPhone:(NSString *)phoneNumber withCompletion:(APICheckResponseBlock)handler {
    NSParameterAssert(phoneNumber.length > 0);
    [RAUserAPI checkAvailabilityOfEmail:nil andPhone:phoneNumber withCompletion:handler];
}

+ (void)checkAvailabilityOfEmail:(NSString *)email andPhone:(NSString *)phoneNumber withCompletion:(APICheckResponseBlock)completion {
    NSString *path = @"users/exists";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"email"] = email;
    parameters[@"phoneNumber"] = phoneNumber;
    
    AFRKHTTPClient *httpClient = [RKObjectManager sharedManager].HTTPClient.copy;
       httpClient.parameterEncoding = AFRKJSONParameterEncoding;
    [httpClient putPath:path parameters:parameters success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        RAUserDataModel *model = [RAJSONAdapter modelOfClass:RAUserDataModel.class fromJSONDictionary:responseObject isNullable:NO];
        if (completion) {
            completion(model, nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:PUTSaveProfile];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
}

+ (void)updateUser:(RAUserDataModel *)user withCompletion:(RAUserAPICompletionBlock)completion {
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"email"]        = user.email;
    params[@"firstname"]    = user.firstname;
    params[@"lastname"]     = user.lastname;
    params[@"phoneNumber"]  = user.phoneNumber;
    params[@"nickName"]     = user.nickName;
    NSString *path = [NSString stringWithFormat:kPathUsersSpecific, user.modelID.stringValue];
    
    AFRKHTTPClient *httpClient = [RKObjectManager sharedManager].HTTPClient.copy;
    httpClient.parameterEncoding = AFRKJSONParameterEncoding;
    [httpClient putPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        RAUserDataModel *model = [RAJSONAdapter modelOfClass:RAUserDataModel.class fromJSONDictionary:responseObject isNullable:NO];
        if (completion) {
            completion(model, nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:PUTSaveProfile];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        if (completion) {
            completion(nil, raError);
        }
    }];
    
}
@end
