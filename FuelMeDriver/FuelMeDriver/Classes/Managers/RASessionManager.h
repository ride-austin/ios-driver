//
//  RASessionManager.h
//  RideDriver
//
//  Created by Roberto Abreu on 14/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RASessionDataModel.h"

@interface RASessionManager : NSObject

typedef void(^RAErrorBlock)(NSError * _Nullable error);

@property (nonatomic) RASessionDataModel * _Nullable currentSession;

+ (RASessionManager *_Nonnull)shared;
- (void)saveUserCarTypes:(NSArray<NSString *> *_Nullable)userCarTypes;
- (void)saveUserCarTypes:(NSArray<NSString *> *_Nullable)userCarTypes andDriverType:(DriverType)driverTypeFilter;
- (BOOL)isSignedIn;

@end


#import "RADriverDataModel.h"

@interface RASessionManager (SignIn)

- (void)loginWithUsername:(NSString *_Nonnull)username
                password:(NSString *_Nonnull)password
           andCompletion:(void(^_Nonnull)(RADriverDataModel * _Nullable, NSError * _Nullable error))completion;

- (void)loginWithFacebookFromViewController:(UIViewController *_Nonnull)viewController
                             andCompletion:(void(^_Nonnull)(RADriverDataModel * _Nullable, NSError * _Nullable error))completion;
@end


@interface RASessionManager (SignOut)

- (void)logoutWithCompletion:(RAErrorBlock _Nullable)completion;
- (void)clearCurrentSession;
- (void)handle401Response:(NSHTTPURLResponse *_Nonnull)response;

@end


@interface RASessionManager (Driver)

- (void)reloadCurrentDriverWithCompletion:(void(^_Nullable)(RADriverDataModel * _Nullable, NSError * _Nullable error))completion;
- (void)updateDriverPhoto:(NSData * _Nonnull)photoData withCompletion:(RAErrorBlock _Nonnull)completion;

@end


@interface RASessionManager (ChangePassword)

- (void)updatePassword:(NSString * _Nonnull)newPassword withCompletion:(void(^ _Nonnull)(NSError * _Nullable error))completion;

@end


@interface RASessionManager (User)

- (void)updateUserEmail:(NSString * _Nonnull)email
              firstName:(NSString * _Nullable)firstName
               lastName:(NSString * _Nullable)lastName
               nickName:(NSString * _Nullable)nickName
            phoneNumber:(NSString * _Nullable)phoneNumber
    withCompletionBlock:(RAErrorBlock _Nonnull)completion;

@end
