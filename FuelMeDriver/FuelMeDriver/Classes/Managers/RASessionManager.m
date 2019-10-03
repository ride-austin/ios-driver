//
//  RASessionManager.m
//  RideDriver
//
//  Created by Roberto Abreu on 14/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RASessionManager.h"

#import "AppDelegate.h"
#import "ConfigurationManager.h"
#import "LocationService.h"
#import "NetworkManager.h"
#import "PersistenceManager.h"
#import "RADriversAPI.h"
#import "RASessionAPI.h"
#import "RAUserAPI.h"
#import "RideDriverConstants.h"
#import "RideUser.h"
#import "VersionManager.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SAMKeychain/SAMKeychain.h>
#import <SDWebImage/SDWebImagePrefetcher.h>

NSString *const kSessionManagerUDKeyCurrentSession = @"kSessionManagerUDKeyCurrentSession";

NSString *const kSessionServiceKeychain = @"kSessionServiceKeychain";
NSString *const kAccountKeychain = @"com.rideaustin.driver";

@interface RASessionManager (Persistence)

- (RASessionDataModel *)cachedSession;
- (void)saveSession:(RASessionDataModel *)session;

@end

@implementation RASessionManager

+ (RASessionManager *)shared {
    static RASessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RASessionManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _currentSession = [self cachedSession];
    }
    return self;
}

#pragma mark - Setters

- (void)setCurrentSession:(RASessionDataModel *)currentSession {
    _currentSession = currentSession;
    [self updateHeader];
    [self saveContext];
}

- (void)updateHeader {
    if (_currentSession.authToken) {
        [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"X-Auth-Token" value:_currentSession.authToken];
    } else {
        [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"X-Auth-Token" value:@""];
    }
}

- (void)saveUserCarTypes:(NSArray<NSString *> *_Nullable)userCarTypes {
    [self saveUserCarTypes:userCarTypes andDriverType:self.currentSession.driverTypeFilter];
}

- (void)saveUserCarTypes:(NSArray<NSString *> *)userCarTypes andDriverType:(DriverType)driverTypeFilter {
    self.currentSession.userCarTypes = userCarTypes.count > 0 ? userCarTypes : nil;
    self.currentSession.driverTypeFilter = driverTypeFilter;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserCarTypesHasBeenChangedNotification object:userCarTypes];
    [self saveContext];
}

- (void)saveContext {
    [self saveSession:self.currentSession];
}

#pragma mark - Getters

- (BOOL)isSignedIn {
    return self.currentSession.authToken != nil;
}

- (void)setUserMetrics:(RADriverDataModel *)driver {
    //Crashlytics
    [CrashlyticsKit setUserIdentifier:driver.modelID.stringValue];
    [CrashlyticsKit setUserEmail:driver.user.email];
    [CrashlyticsKit setUserName:driver.user.fullName];
    
    //BugFender
    [Bugfender setDeviceString:(driver.modelID.stringValue ?: @"Unknown") forKey:@"DRIVER_ID"];
    [Bugfender setDeviceString:(driver.user.email ?: @"Unknown") forKey:@"EMAIL"];
    [Bugfender setDeviceString:(driver.user.fullName ?: @"Unknown") forKey:@"FULLNAME"];
}

@end

@implementation RASessionManager (Persistence)

- (RASessionDataModel *)cachedSession {
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:kSessionManagerUDKeyCurrentSession];
    if (data) {
        [SAMKeychain setPasswordData:data forService:kSessionServiceKeychain account:kAccountKeychain];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSessionManagerUDKeyCurrentSession];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    data = [SAMKeychain passwordDataForService:kSessionServiceKeychain account:kAccountKeychain];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return nil;
}

- (void)saveSession:(RASessionDataModel *)session {
    if (session) {
        [session cachePreferencesToEmail];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:session];
        [SAMKeychain setPasswordData:data forService:kSessionServiceKeychain account:kAccountKeychain];
    } else {
        [SAMKeychain deletePasswordForService:kSessionServiceKeychain account:kAccountKeychain];
    }
}

@end

@implementation RASessionManager (SignIn)

- (void)loginWithUsername:(NSString *_Nonnull)username
                 password:(NSString *_Nonnull)password
            andCompletion:(void (^ _Nonnull)(RADriverDataModel * _Nullable, NSError * _Nullable))completion {
    [self loginWithUsername:username password:password isFacebookUser:NO andCompletion:completion];
}

- (void)loginWithFacebookFromViewController:(UIViewController *_Nonnull)viewController
                              andCompletion:(void (^ _Nonnull)(RADriverDataModel * _Nullable, NSError * _Nullable))completion {
    NSParameterAssert(viewController);
    NSParameterAssert(completion);
    __weak __typeof__(self) weakself = self;
    FBSDKLoginManager *login = [FBSDKLoginManager new];
    [login logInWithReadPermissions:@[@"public_profile", @"email"] fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            BOOL userDidntAllowToOpenFacebook = [error.domain isEqualToString:@"com.apple.SafariServices.Authentication"] && error.code == 1;
            if (userDidntAllowToOpenFacebook) {
                error = nil;
            }
            completion(nil, error);
            
        } else if (result.isCancelled) {
            completion(nil, nil);
            
        } else {
            NSDictionary *paramaters = @{@"fields":@"id,name,email,first_name,last_name"};
            FBSDKGraphRequest *gr = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:paramaters];
            [gr startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *grError) {
                if (grError) {
                    completion(nil, grError);
                } else {
                    NSString *email = result[@"email"];
                    NSString *facebookToken = [FBSDKAccessToken currentAccessToken].tokenString;
                    if (email && facebookToken) {
                        [RASessionAPI loginWithFacebook:facebookToken andCompletion:^(NSError *loginError) {
                            if (loginError) {
                                completion(nil, loginError);
                            } else {
                                [weakself loginWithUsername:email password:facebookToken isFacebookUser:YES andCompletion:completion];
                            }
                        }];
                    } else if (!email) {
                        completion(nil, self.noEmailError);
                    } else if (!facebookToken) {
                        completion(nil, self.noFBTokenError);
                    }
                }
            }];
        }
    }];
}

#pragma mark - Private

- (NSError *)noFBTokenError {
    NSString *appName = [ConfigurationManager appName];
    NSString *message = [NSString stringWithFormat:@"We are unable to login with Facebook at this moment. Please check your permissions for %@ and/or create a %@ account using your email.", appName, appName];
    NSError *error = [NSError errorWithDomain:@"com.rideaustin.error.facebook.token.notFound" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey : message}];
    return error;
}

- (NSError *)noEmailError {
    NSString *appName = [ConfigurationManager appName];
    NSString *message = [NSString stringWithFormat:@"We are unable to access your email associated with Facebook.\nPlease check your permissions for %@ and/or create a %@ account using your email", appName, appName];
    NSError *error = [NSError errorWithDomain:@"com.rideaustin.error.facebook.email.notFound" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey : message}];
    return error;
}

- (void)loginWithUsername:(NSString *)username
                password:(NSString *)password
          isFacebookUser:(BOOL)isFacebookUser
           andCompletion:(void (^ _Nonnull)(RADriverDataModel * _Nullable, NSError * _Nullable))completion {
    NSParameterAssert([username isKindOfClass:[NSString class]]);
    NSParameterAssert([password isKindOfClass:[NSString class]]);
    NSParameterAssert(completion);
    [RASessionAPI loginWithUsername:username password:password encrypt:!isFacebookUser andCompletion:^(RASessionDataModel *session, NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            __weak __typeof__(self) weakself = self;
            
            self.currentSession = session;
            [self.currentSession restorePreferencesForEmail:username];
            [self reloadCurrentDriverWithCompletion:^(RADriverDataModel *driver, NSError *error) {
                if (error) {
                    weakself.currentSession = nil;
                    completion(nil, error);
                } else {
                    if (driver.user.hasDriverAvatar == NO) {
                        weakself.currentSession = nil;
                        NSString *errorMessage = [NSString stringWithFormat:@"Please contact %@ to activate you as a driver.",[ConfigurationManager appName]];
                        NSError *notADriverError = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
                        completion(nil, notADriverError);
                    } else {
                        if ([driver.photoUrl isKindOfClass:[NSURL class]]) {
                            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:@[driver.photoUrl]];
                        }
                        
                        [[LocationService sharedService] start];
                        completion(driver, nil);
                    }
                }
            }];
        }
    }];
}

@end

@implementation RASessionManager (SignOut)

- (void)logoutWithCompletion:(RAErrorBlock)completion {
    if (self.isSignedIn) {
        __weak __typeof__(self) weakself = self;
        [RASessionAPI logoutWithCompletion:^(NSError * _Nullable error) {
            [weakself clearCurrentSession];
            if (completion) {
                completion(error);
            }
        }];
    } else {
        [self clearCurrentSession];
        if (completion) {
            completion(nil);
        }
    }
}

- (void)clearCurrentSession {
    self.currentSession = nil;
    [VersionManager resetOptionalUpgradeDate];
    [PersistenceManager removeCachedDeviceToken];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    [[RKManagedObjectStore defaultStore] resetPersistentStores:nil];
    
    //Are we authenticated via facebook.
    if([FBSDKAccessToken currentAccessToken] != nil) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
    }
    
    // Clear cookies
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
        DBLog(@"deleted cookie");
    }
    
    [[LocationService sharedService] stop];
    
    //move this to navigator
    [(AppDelegate*)[UIApplication sharedApplication].delegate showSplashScreen];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSignoutNotification object:nil];
}

- (void)clearAuthToken {
    self.currentSession = nil;
}

- (void)handle401Response:(NSHTTPURLResponse *)response {
    if (response.statusCode == 401) {
        if ([response.URL.absoluteString hasSuffix:kPathLogout]) {
            [self clearCurrentSession]; //clear session only
        } else if ([response.URL.path hasSuffix:kPathLogin]) {
            [self clearAuthToken]; //clear auth token only
        } else {
            [self logoutWithCompletion:nil]; //completely logout
        }
    }
}

@end

@implementation RASessionManager (Driver)

- (void)reloadCurrentDriverWithCompletion:(void (^)(RADriverDataModel * _Nullable, NSError * _Nullable))completion {
    [RADriversAPI getDriversCurrentWithCompletion:^(RADriverDataModel *driver, NSError *error) {
        if (!error) {
            self.currentSession.driver = driver;
            [self setUserMetrics:driver];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentDriverHasBeenChangedNotification object:nil];
        }
        if (completion) {
            completion(driver, error);
        }
    }];
}

- (void)updateDriverPhoto:(NSData *)photoData withCompletion:(void(^)(NSError *error))completion {
    NSParameterAssert([photoData isKindOfClass:[NSData class]]);
    NSParameterAssert(completion);
    __weak __typeof__(self) weakself = self;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"photoData"] = photoData;
    [[NetworkManager sharedInstance] postDriverPhotoWithParams:params andDriverID:self.currentSession.driver.modelID.stringValue uploadCompleteBlock:^(NSString *photoUrl, NSError *error) {
        if (!error) {
            weakself.currentSession.driver.photoUrl = [NSURL URLWithString:photoUrl];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserPhotoHasBeenChangedNotification object:nil];
            [weakself saveContext];
        }
        completion(error);
    }];
}

@end

@implementation RASessionManager (ChangePassword)

- (void)updatePassword:(NSString *)newPassword withCompletion:(void (^)(NSError *))completion {
    NSString *email = self.currentSession.driver.email;
    NSString *securePassword = [RASessionAPI securePasswordWithEmail:email andPassword:newPassword];
    [RASessionAPI updatePassword:securePassword withCompletion:completion];
}

@end

@implementation RASessionManager (User)

- (void)updateUserEmail:(NSString *)email
             firstName:(NSString *)firstName
              lastName:(NSString *)lastName
              nickName:(NSString *)nickName
           phoneNumber:(NSString *)phoneNumber withCompletionBlock:(void(^)(NSError *error))completion {
    NSParameterAssert(completion);
    __weak __typeof__(self) weakself = self;
    
    RAUserDataModel *userCopy = self.currentSession.driver.user.copy;
    [userCopy updateEmail:email firstname:firstName lastname:lastName nickName:nickName phoneNumber:phoneNumber];
    [RAUserAPI updateUser:userCopy withCompletion:^(RAUserDataModel *user, NSError *error) {
        if (!error) {
            weakself.currentSession.driver.user = user; //better to update user instead of replace
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserPropertiesHaveBeenChangedNotification object:nil];
            [weakself saveContext];
        }
        completion(error);
    }];
}

@end
