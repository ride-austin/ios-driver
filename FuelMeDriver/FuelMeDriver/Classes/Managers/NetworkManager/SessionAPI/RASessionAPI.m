//
//  RASessionAPI.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RASessionAPI.h"

#import "AppConfig.h"
#import "NSString+Ride.h"

@implementation RASessionAPI

@end

@implementation RASessionAPI (SignIn)

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password encrypt:(BOOL)encrypt andCompletion:(void (^)(RASessionDataModel *session, NSError *error))completion {
    NSParameterAssert([username isKindOfClass:[NSString class]]);
    NSParameterAssert([password isKindOfClass:[NSString class]]);
    
    NSString *passwordEncripted = encrypt ? [self securePasswordWithEmail:username andPassword:password] : password;
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient.copy; //should not add Authorization to other requests
    [client setAuthorizationHeaderWithUsername:username password:passwordEncripted];
    [client setParameterEncoding:AFRKFormURLParameterEncoding];
    [client postPath:kPathLogin parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            RASessionDataModel *session = [RAJSONAdapter modelOfClass:RASessionDataModel.class fromJSONDictionary:responseObject isNullable:NO];
            completion(session, nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:POSTLogin];
        if (completion) {
            NSError *raError = [error filteredErrorAtReponse:operation.response];
            completion(nil, raError);
        }
    }];
}

+ (void)loginWithFacebook:(NSString *)facebookToken andCompletion:(void (^)(NSError *error))completion {
    NSParameterAssert([facebookToken isKindOfClass:[NSString class]]);
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"token"] = facebookToken;
    NSString *path = kPathFacebook;
    [[RKObjectManager sharedManager].HTTPClient setParameterEncoding: AFRKFormURLParameterEncoding];
    [[RKObjectManager sharedManager].HTTPClient postPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        [ErrorReporter recordError:error withDomainName:POSTFacebookRegister];
        if (completion) {
            NSError *raError = [error filteredErrorAtReponse:operation.response];
            completion(raError);
        }
    }];
}
@end


@implementation RASessionAPI (SignOut)

+ (void)logoutWithCompletion:(void (^)(NSError * _Nullable))completion {
    NSString *path = kPathLogout;
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    [client setParameterEncoding:AFRKFormURLParameterEncoding];
    [client postPath:path parameters:nil success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        //[ErrorReporter recordError:error withDomainName:POSTLog];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        completion(raError);
    }];
}

@end

@implementation RASessionAPI (ChangePassword)

+ (void)updatePassword:(NSString *)password withCompletion:(void (^)(NSError * _Nullable))completion {
    NSParameterAssert(password);
    NSString *path = kPathPassword;
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"password"] = password;
    
    AFRKHTTPClient *client = [RKObjectManager sharedManager].HTTPClient;
    [client setParameterEncoding:AFRKFormURLParameterEncoding];
    [client postPath:path parameters:params success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
//        [ErrorReporter recordError:error withDomainName:];
        NSError *raError = [error filteredErrorAtReponse:operation.response];
        completion(raError);
    }];
}

@end

@implementation RASessionAPI (SecurePassword)

+ (NSString *)securePasswordWithEmail:(NSString *)email andPassword:(NSString *)password {
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@", [email lowercaseString], [AppConfig md5PasswordSalt], password];
    return [pwd md5];
}

@end
