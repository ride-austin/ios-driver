//
//  RASessionAPI.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseAPI.h"
#import "RASessionDataModel.h"

@interface RASessionAPI : RABaseAPI

@end

@interface RASessionAPI (SignIn)

+ (void)loginWithUsername:(NSString * _Nonnull)username password:(NSString * _Nonnull)password encrypt:(BOOL)encrypt andCompletion:(void(^ _Nonnull)(RASessionDataModel * _Nullable session, NSError * _Nullable error))completion;
+ (void)loginWithFacebook:(NSString * _Nonnull)facebookToken andCompletion:(void(^ _Nonnull)(NSError * _Nullable error))completion;

@end

@interface RASessionAPI (SignOut)

+(void)logoutWithCompletion:(void(^ _Nonnull)(NSError * _Nullable error))completion;

@end

@interface RASessionAPI (ChangePassword)

+ (void)updatePassword:(NSString * _Nonnull)password withCompletion:(void(^ _Nonnull)(NSError * _Nullable error))completion;

@end

@interface RASessionAPI (SecurePassword)

+ (NSString *_Nonnull)securePasswordWithEmail:(NSString *_Nonnull)email andPassword:(NSString *_Nonnull)password;

@end
