//
//  ConfigurationManager.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/2/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ConfigurationManager.h"

#import "CarCategoriesManager.h"
#import "ErrorReporter.h"
#import "JSONHandler.h"
#import "NetworkManager.h"
#import "PersistenceManager.h"
#import "RADriverDataModel.h"
#import "RADriversAPI.h"
#import "RASessionManager.h"
#import "RideDriver-Swift.h"

NSString* const kNotificationDidChangeConfiguration = @"kNotificationDidChangeConfiguration";
NSString* const kNotificationDidChangeCurrentCityType = @"kNotificationDidChangeCurrentCityType";

// DEPLOYMENT: the url for the latest version of Driver should be served by server, but until it is, this url must be updated
NSString * const kLatestDriverAustinVersionDownloadURL = @"https://rink.hockeyapp.net/apps/84e082dbcaf040b0acb3571894c0ad74"; //RideAustin
NSString * const kLatestDriverHoustonVersionDownloadURL = @"https://rink.hockeyapp.net/apps/2169a86c75064d64bdb65d033b41057b"; //RideHouston (for now it is private, update if necessary)

@interface ConfigurationManager ()
@property (nonatomic) BOOL needsReconfiguration;
@end

@implementation ConfigurationManager

+ (instancetype)shared {
    static ConfigurationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        
        //RA-5572 - load cached global config
        if ([PersistenceManager hasConfigGlobal]) {
            manager.global = [PersistenceManager cachedConfigGlobal];
        } else {
            //RA-5572 - Load default config local file
            //NOTE: Austin or Houston depends on target macros
            [ConfigurationManager loadDefaultConfigWithCompletion:^(ConfigGlobal *config, NSError *error){
                
                if (!error) {
                    manager.global = config;
                } else {
                    [ErrorReporter recordError:error withDomainName:LoadConfigData];
                }
                
            }];
        }
        
        manager.needsReconfiguration = YES;
    });
    
    return manager;
}

/**
 * @brief load default global config with completion
 *
 */
+ (void)loadDefaultConfigWithCompletion:(RAConfigGlobalCompletionBlock)handler {
    [JSONHandler getConfigGlobalWithCompletion:^(ConfigGlobal *config, NSError *error){
        if (!error) {
            handler(config, nil);
        } else {
            handler(nil, error);
        }
    }];
}


- (void)setGlobal:(ConfigGlobal *)global {
    // workaround until provided by server
    if (_global.driverTypes) {
        global.driverTypes = _global.driverTypes;
    }
    /////////////////////
    _global = global;
    
    [CarCategoriesManager prefetchCarCategoryIconsFromCarTypes:global.carTypes];
    //RA-5572 - save global config on persistence
    [PersistenceManager saveConfigGlobal:global];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeConfiguration object:nil];
    [self updateDriverTypesWithCompletion:nil];
}

+ (void)needsReload {
    [ConfigurationManager shared].needsReconfiguration = YES;
}

+ (void)checkConfigurationBasedOnLocation:(CLLocation *)location {
    if ([RASessionManager shared].isSignedIn) {
        [[ConfigurationManager shared] checkConfigurationBasedOnLocation:location];
    }
}

- (void)checkConfigurationBasedOnLocation:(CLLocation *)location {
    if (self.needsReconfiguration) {
        __weak __typeof__(self) weakself = self;
        self.needsReconfiguration = NO;
        [RAConfigAPI getGlobalConfigurationAtCoordinate:location.coordinate completion:^(ConfigGlobal * _Nullable globalConfig, NSError * _Nullable error) {
            if (error) {
                weakself.needsReconfiguration = YES;
            } else {
                weakself.global = globalConfig;
                [weakself setCurrentCityType:weakself.global.currentCity.cityType];
            }
        }];
    }
}

#pragma mark - City configuration
- (void)setCurrentCityType:(CityType)currentCityType {
    if ([ConfigurationManager getCurrentCityType] != currentCityType) {
        [PersistenceManager saveCurrentCityType:currentCityType];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeCurrentCityType object:nil];
    }
}

+ (RACity *)getRegisteredCity {
    return [self getCityWithID:[RASessionManager shared].currentSession.driver.cityId];
}

+(RACity *)getCityWithID:(NSNumber *)cityID {
    NSArray *matchedCities = [[ConfigurationManager shared].global.supportedCities filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RACity * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.cityID isEqualToNumber:cityID];
    }]];
    return matchedCities.firstObject;
}

+ (CityType)getCurrentCityType {
    if ([PersistenceManager hasCurrentCityTypeSaved]) {
        return [PersistenceManager currentCityType];
    } else {
        return Austin;
    }
}

+ (NSString *)localAppName {
    NSString *name = [[NSBundle mainBundle].infoDictionary objectForKey:(NSString*)kCFBundleNameKey];
    return name;
}

+ (NSString *)appName {
    return [ConfigurationManager shared].global.generalInfo.appName ?: [ConfigurationManager localAppName];
}

+ (NSString *)appPrefix {
    NSString *cityName = [ConfigurationManager shared].global.currentCity.name;
    if (cityName && cityName.length > 0) {
        NSString *firstLetter = [cityName substringToIndex:1].uppercaseString;
        return [NSString stringWithFormat:@"R%@",firstLetter];
    } else {
        return @"RA";
    }
}

+ (NSURL *)defaultLatestDriverAppDownloadURL{
    CityType currentCity = [self getCurrentCityType];
    
    NSURL *url = nil;
    
    switch (currentCity) {
        case Austin:
            url = [NSURL URLWithString:kLatestDriverAustinVersionDownloadURL];
            break;
        case Houston:
            url = [NSURL URLWithString:kLatestDriverHoustonVersionDownloadURL];
            break;
            
        default:
            break;
    }
    return url;
}

- (void)updateDriverTypesWithCompletion:(void (^)(NSError *error))completion {
    __weak __typeof__(self) weakself = self;
    //Temporary Workaround - Configuration should return driverTypes
    [RADriversAPI getDriverTypesForCity:self.global.currentCity.cityID withCompletion:^(NSArray<RADriverType *> *driverTypes, NSError *error) {
        if (!error) {
            weakself.global.driverTypes = driverTypes;
        }
        if (completion) {
            completion(error);
        }
    }];
}

@end
