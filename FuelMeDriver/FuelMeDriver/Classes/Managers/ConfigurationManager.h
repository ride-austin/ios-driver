//
//  ConfigurationManager.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/2/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigGlobal.h"
#import "ConfigReferFriend.h"
#import "RACity.h"
@class RADriverDataModel;
extern NSString* const kNotificationDidChangeConfiguration;
extern NSString* const kNotificationDidChangeCurrentCityType;

@interface ConfigurationManager : NSObject

@property (nonatomic) ConfigGlobal *global;

+ (instancetype)shared;
+ (void)needsReload;
+ (void)checkConfigurationBasedOnLocation:(CLLocation *)location;
+ (CityType)getCurrentCityType;
/**
 *  @return city where the driver is registered
 */
+ (RACity *)getRegisteredCity;
+ (RACity *)getCityWithID:(NSNumber *)cityID;
/**
 *  @brief exactly the name of the app
 */
+ (NSString *)localAppName;
/**
 *  @brief name based on city
 */
+ (NSString *)appName;
+ (NSString *)appPrefix;

+ (NSURL*)defaultLatestDriverAppDownloadURL;

@end
