//
//  VersionManager.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/26/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "VersionManager.h"

#import "ConfigurationManager.h"
#import "DriverManager.h"
#import "NSDate+Utils.h"
#import "NSString+CompareToVersion.h"
#import "NSString+Utils.h"
#import "RideDriver-Swift.h"
#import "RAAlertManager.h"

typedef NS_ENUM(NSInteger, VersionAlertType) {
    NoneVersionAlertType,
    OptionalVersionAlertType,
    MandatoryVersionAlertType
};

static NSTimeInterval const kMinTimeInterval = 12*3600; // 12 hours minimum to show again the enforncing upgrading message if not mandatory.
static NSString *const kLastOptionalUpgradeMessageShownDateUD = @"kLastOptionalUpgradeMessageShownDateUD";

//version format pattern AnyInt.AnyInt.AnyInt
static NSString *const kVersionPattern = @"[0-9]+\\.[0-9]+\\.[0-9]+";

@interface VersionManager ()

@property (nonatomic, strong) RAConfigAppDataModel *currentAppConfig;
@property (nonatomic, assign) VersionAlertType currentAlertType;

+ (VersionManager*)sharedManager;

+ (void)updateLatsOptionalMessageShownDate;
+ (BOOL)shouldShowNotMandatoryAlert;

@end

@interface VersionManager (Private)

- (void)checkNewVersionAvailableWithCompletion:(RAVerifyVersionCompletionBlock)handler;
- (void)showAlertMandatory:(BOOL)isMandatory withDownloadURL:(NSURL*)downloadURL;

@end

@implementation VersionManager

+ (VersionManager *)sharedManager {
    static VersionManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [VersionManager new];
        _sharedManager.currentAlertType = NoneVersionAlertType;
    });
    return _sharedManager;
}

/**
 *  @return Current Version e.g. 81
 */
+ (NSString *)currentVersion {
    //Version 1.1.5b
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [self removeCharsFromString:appVersion];
}
/**
 *  @return Current Build e.g. 81
 */
+ (NSInteger)currentBuild {
    return [[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"] integerValue];
}

+ (NSString *)removeCharsFromString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"a" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"b" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"rc" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    return string;
}

+ (NSDate *)lastOptionalMessageShownDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastOptionalUpgradeMessageShownDateUD];
}

+ (void)updateLatsOptionalMessageShownDate {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate trueDate] forKey:kLastOptionalUpgradeMessageShownDateUD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)resetOptionalUpgradeDate {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kLastOptionalUpgradeMessageShownDateUD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldShowNotMandatoryAlert {
    NSDate *lastDate = [VersionManager lastOptionalMessageShownDate];
    if (!lastDate) {
        return YES;
    }
    return ([[NSDate trueDate] timeIntervalSinceDate:lastDate] > kMinTimeInterval);
}

+ (void)checkNewVersionAvailableWithCompletion:(RAVerifyVersionCompletionBlock)handler {
#ifdef AUTOMATION
    if (handler) {
        handler(NO,NO);
    }
    return;
#endif
    [[VersionManager sharedManager] checkNewVersionAvailableWithCompletion:handler];
}

+ (void)showAlertIfNeeded {
    RAConfigAppDataModel *currentAppConfig = [[VersionManager sharedManager] currentAppConfig];
    if (![currentAppConfig shouldUpgrade]) {
        return;
    }
    
    BOOL mandatoryUpgrade = [currentAppConfig isMandatory];
    
    //Avoid overlaping alert of same type
    VersionAlertType currentAlertType = [VersionManager sharedManager].currentAlertType;
    if (currentAlertType == NoneVersionAlertType || (currentAlertType == OptionalVersionAlertType && mandatoryUpgrade)) {
        NSURL *downloadURL = currentAppConfig.upgradeURL ?: [ConfigurationManager defaultLatestDriverAppDownloadURL];
        if (mandatoryUpgrade || [VersionManager shouldShowNotMandatoryAlert]) {
            [[VersionManager sharedManager] showAlertMandatory:mandatoryUpgrade withDownloadURL:downloadURL];
        }
    }
}

@end


@implementation VersionManager (Private)

-(void)checkNewVersionAvailableWithCompletion:(RAVerifyVersionCompletionBlock)handler{
    __weak VersionManager *weakSelf = self;
    [RAConfigAPI getVersionInfoWithCompletion:^(RAConfigAppDataModel * _Nullable appConfiguration, NSError * _Nullable error) {
        if (!appConfiguration || appConfiguration.version.length == 0) {
            weakSelf.currentAppConfig = nil;
            
            if (handler) {
                handler(NO,NO);
            }
            return;
        }
        
        weakSelf.currentAppConfig = appConfiguration;
        
        if (handler) {
            handler([appConfiguration shouldUpgrade],[appConfiguration isMandatory]);
        }
    }];
}

- (void)showAlertMandatory:(BOOL)isMandatory withDownloadURL:(NSURL *)downloadURL{
    __weak VersionManager *weakSelf = self;
    NSString *message = nil;

    if (isMandatory) {
        message = [NSString stringWithFormat:@"A new version of %@ is available, and you must update to the new version before going online.",[ConfigurationManager localAppName]];
    } else {
        message = [NSString stringWithFormat:@"A new version of %@ is available.",[ConfigurationManager localAppName]];
    }
    
    RAAlertOption *option = [RAAlertOption optionWithShownOption:Overlap];
    RAAlertAction *appStoreAction = [RAAlertAction actionWithTitle:@"Get New Version"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nullable action) {
                                                               [[UIApplication sharedApplication] openURL:downloadURL];
                                                               weakSelf.currentAlertType = NoneVersionAlertType;
                                                           }];
    [option addAction:appStoreAction];
    
    if (isMandatory) {
        self.currentAlertType = MandatoryVersionAlertType;
        [RAAlertManager showAlertWithTitle:@"New Version Available" message:message options:option];
    } else {
        self.currentAlertType = OptionalVersionAlertType;
        [VersionManager updateLatsOptionalMessageShownDate];
        
        RAAlertAction *cancelAction = [RAAlertAction actionWithTitle:@"Not Now"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nullable action) {
                                                                 weakSelf.currentAlertType = NoneVersionAlertType;
                                                             }];
        [option addAction:cancelAction];
        
        [RAAlertManager showAlertWithTitle:@"New Version Available" message:message options:option];
    }
}

@end
