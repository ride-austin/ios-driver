//
//  PersistenceManager.h
//  RideDriver
//
//  Created by Carl von Havighorst on 6/20/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "ActionViewDefines.h"
#import "RACity.h"
#import "RARideCache.h"
#import "RARideDataModel.h"
#import "RideDriverEnums.h"
#import "SoundManagerDefines.h"

@class Car;
@class ConfigGlobal;
@class RideRate;
@interface PersistenceManager : NSObject
+ (PersistenceManager*)sharedInstance;

#pragma mark - DriverState
+ (void)saveDriverState:(DriverState)driverState;
+ (DriverState)cachedDriverState;

#pragma mark - Ride Events Cache
+ (void)saveRideCaches:(NSMutableArray<RARideCache *> *)rideCaches;
+ (NSMutableArray<RARideCache *> *)rideCaches;

#pragma - RideRequest
+ (BOOL)shouldShowStartTripReminderNotification;
+ (void)enableShowStartTripReminderNotification:(BOOL)enabled;

#pragma mark - Unrated Ride
+ (BOOL)hasUnratedRide;
+ (void)saveUnratedRideData:(RARideDataModel *)rideDataModel;
+ (void)removeUnratedRide:(RARideDataModel *)rideDataModel;
+ (NSMutableArray<RARideDataModel *> *)cachedUnratedRides;

#pragma mark - Ride rated pending to upload
+ (void)saveRideRate:(RideRate*)rideRate;
+ (void)removeRideRate:(RideRate*)rideRate;
+ (NSMutableArray<RideRate*>*)pendingToUploadRideRate;
+ (void)removePendingRideRate;

#pragma mark - Save Default Navigation App
+ (BOOL)hasDefaultNavigationApp;
+ (void)saveDefaultNavigationApp:(NavigationApp)navigationApp;
+ (NavigationApp)cachedDefaultNavigationApp;

#pragma mark - Save Default Call Settings
+(BOOL)hasCallSetting;
+(void)saveCallSetting:(CallSetting)callSetting;
+(CallSetting)cachedCallSetting;

#pragma mark - Save last eventID
+(long long)cachedEventIDReceived;
+(void)saveEventID:(long long)eventID;

#pragma mark - Location Settings Services
+(BOOL)hasLocationsSettings;
+(void)saveLocationSettings:(BOOL)enabled;

#pragma mark - Current City
+ (BOOL)hasCurrentCityTypeSaved;
+ (void)saveCurrentCityType:(CityType)cityType;
+ (CityType)currentCityType;

#pragma mark - Cached Config Global
+ (BOOL)hasConfigGlobal;
+ (void)saveConfigGlobal:(ConfigGlobal*)config;
+ (ConfigGlobal*)cachedConfigGlobal;

#pragma mark - Device Token
+ (NSString *)cachedDeviceToken;
+ (void)saveRegisteredDeviceToken:(NSString *)deviceToken;
+ (void)removeCachedDeviceToken;

#pragma mark - Selected Car
+ (BOOL)hasPreviouslySelectedCar;
+ (Car*)selectedCar;
+ (void)saveSelectedCar:(Car*)car;

#pragma mark - Helpers
+ (BOOL)hasKeyDefined:(NSString*)key;

@end
