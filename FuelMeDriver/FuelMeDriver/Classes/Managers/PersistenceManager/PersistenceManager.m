//
//  PersistenceManager.m
//  RideDriver
//  Ride Austin Driver Persistence Manager
//
//  Created by Carl von Havighorst on 6/20/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "PersistenceManager.h"

#import "Car.h"
#import "ConfigGlobal.h"
#import "ErrorReporter.h"
#import "PersistenceManagerConstants.h"
#import "RASessionManager.h"
#import "RideRate.h"
#import "RideUser.h"

#define defaults [NSUserDefaults standardUserDefaults]
#define userKey(x) [self appendUserToKey:x]

@implementation PersistenceManager

+ (PersistenceManager*)sharedInstance {
    static PersistenceManager *dbManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbManager = [[self alloc] init];
    });
    
    return dbManager;
}

#pragma mark - Helpers
+ (BOOL)hasKeyDefined:(NSString*)key {
    return [[[defaults dictionaryRepresentation] allKeys] containsObject:key];
}

+ (void)storeObject:(id)object forRawKey:(NSString *)rawKey {
    NSString *key = [self appendUserToKey:rawKey];
    if (key) {
        id existing = [defaults objectForKey:key];
        if (object) {
            if ([object isEqual:existing]) {
                return;
            }
            [defaults setObject:object forKey:key];
        } else {
            if (existing == nil) {
                return;
            }
            [defaults removeObjectForKey:key];
        }
        [defaults synchronize];
    }
    else{
        CLSLog(@"Key is null - rawKey: %@",rawKey);
    }
}

/**
 *  @param rawKey - key that needs to convert to userKey
 *  @param finalKey - key that will be used without convertin
 */
+ (void)archiveObject:(id)object forRawKey:(NSString *)rawKey {
    NSString *key = [self appendUserToKey:rawKey];
    if (key) {
        [PersistenceManager archiveObject:object forFinalKey:key];
    } else {
        DBLog(@"Key is null - rawKey: %@",rawKey);
    }
    
}

+ (void)archiveObject:(id)object forFinalKey:(NSString *)finalKey {
    NSString *key = finalKey;
    id existing = [defaults objectForKey:key];
    if (object) {
        if ([object isEqual:existing]) {
            return;
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        [defaults setObject:data   forKey:key];
    } else {
        if (existing == nil) {
            return;
        }
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
}

+ (id)cachedObjectForKey:(NSString *)rawKey {
    NSString *key = [self appendUserToKey:rawKey];
    if (key) {
        return [PersistenceManager cachedObjectForFinalKey:key];
    } else {
        DBLog(@"Key is null - rawKey: %@",rawKey);
        return nil;
    }
}

+ (id)cachedObjectForFinalKey:(NSString *)finalKey {
    NSString *key = finalKey;
    NSData *encodedObject = [defaults dataForKey:key];
    
    if (encodedObject) {
        id object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        return object;
    } else {
        DBLog(@"Encoded Object is NULL");
        return nil;
    }
}

+ (NSString *)appendUserToKey:(NSString *)rawKey {
    NSString *userId = [RASessionManager shared].currentSession.driver.user.modelID.stringValue;
    if (userId && rawKey && [rawKey isKindOfClass:[NSString class]]) {
        if ([userId isKindOfClass:[NSString class]]) {
            return [userId stringByAppendingString:rawKey];
        } else {
            NSParameterAssert(userId);
            return rawKey;
        }
    }
    return rawKey;
}

#pragma mark - DriverState
+ (void)saveDriverState:(DriverState)driverState {
    [defaults setInteger:driverState forKey:userKey(kDriverStateKey)];
}

+ (DriverState)cachedDriverState {
    return [defaults integerForKey:userKey(kDriverStateKey)];
}

#pragma mark - Ride Events Cache
+ (void)saveRideCaches:(NSMutableArray<RARideCache *> *)rideCaches {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rideCaches];
    [defaults setObject:data forKey:userKey(kRideCaches)];
    [defaults synchronize];
}

+ (NSMutableArray<RARideCache *> *)rideCaches {
    NSData *data = [defaults objectForKey:userKey(kRideCaches)];
    return [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
}

#pragma - RideRequest
+ (BOOL)shouldShowStartTripReminderNotification {
    NSString *key = userKey(kShouldShowStartTripNotification);
    return [self hasKeyDefined:key] ? [defaults boolForKey:key] : YES;
}

+ (void)enableShowStartTripReminderNotification:(BOOL)enabled {
    [defaults setBool:enabled forKey:userKey(kShouldShowStartTripNotification)];
}

#pragma mark - Unrated Ride

+ (BOOL)hasUnratedRide {
    return [self cachedUnratedRides].count > 0;
}

+ (void)saveUnratedRideData:(RARideDataModel *)rideDataModel {
    NSData *rideUnratedData = [NSKeyedArchiver archivedDataWithRootObject:rideDataModel];
    NSMutableArray *mutableList = (NSMutableArray*)[[defaults objectForKey:userKey(kUnratedRides)] mutableCopy];
    
    if (!mutableList) {
        mutableList = [[NSMutableArray alloc] init];
    }
    
    [mutableList addObject:rideUnratedData];
    [defaults setObject:mutableList forKey:userKey(kUnratedRides)];
    [defaults synchronize];
}

+ (void)removeUnratedRide:(RARideDataModel *)rideDataModel {
    NSMutableArray *mutableList = (NSMutableArray*)[[defaults objectForKey:userKey(kUnratedRides)] mutableCopy];
    if (mutableList) {
        for (NSData *unratedRideData in [mutableList copy]) {
            RARideDataModel *rideDataModelTmp = (RARideDataModel *)[NSKeyedUnarchiver unarchiveObjectWithData:unratedRideData];
            if ([rideDataModel.modelID isEqualToNumber:rideDataModelTmp.modelID]) {
                [mutableList removeObject:unratedRideData];
            }
        }
        [defaults setObject:mutableList forKey:userKey(kUnratedRides)];
        [defaults synchronize];
    }
}

+ (NSMutableArray<RARideDataModel *> *)cachedUnratedRides {
    NSMutableArray<RARideDataModel *> *unratedRides = [NSMutableArray array];
    NSMutableArray *mutableList = [defaults objectForKey:userKey(kUnratedRides)];
    
    for (NSData *rideData in mutableList) {
        RARideDataModel *rideDataModel = (RARideDataModel *)[NSKeyedUnarchiver unarchiveObjectWithData:rideData];
        [unratedRides addObject:rideDataModel];
    }
    
    return unratedRides;
}

#pragma mark - Ride rated pending to upload

+ (void)saveRideRate:(RideRate*)rideRate{
    NSData *rideRateData = [NSKeyedArchiver archivedDataWithRootObject:rideRate];
    NSMutableArray *mutableList = (NSMutableArray*)[[defaults objectForKey:userKey(kRideRatedPendingToUpload)] mutableCopy];
    
    if (!mutableList) {
        mutableList = [[NSMutableArray alloc] init];
    }
    
    [mutableList addObject:rideRateData];
    [defaults setObject:mutableList forKey:userKey(kRideRatedPendingToUpload)];
    [defaults synchronize];
}

+ (void)removeRideRate:(RideRate*)rideRate{
    NSMutableArray *mutableList = (NSMutableArray*)[[defaults objectForKey:userKey(kRideRatedPendingToUpload)] mutableCopy];
    
    if (mutableList) {
        for (NSData *rideData in [mutableList copy]) {
            RideRate *rideRateTmp = (RideRate*)[NSKeyedUnarchiver unarchiveObjectWithData:rideData];
            if ([rideRate isEqual:rideRateTmp]) {
                [mutableList removeObject:rideData];
            }
        }
        [defaults setObject:mutableList forKey:userKey(kRideRatedPendingToUpload)];
        [defaults synchronize];
    }
}

+ (NSMutableArray<RideRate *> *)pendingToUploadRideRate{
    NSMutableArray<RideRate*> *pendingRideRate = [NSMutableArray array];
    NSMutableArray *mutableList = [defaults objectForKey:userKey(kRideRatedPendingToUpload)];
    
    for (NSData *rideData in mutableList) {
        RideRate *riteRate = (RideRate*)[NSKeyedUnarchiver unarchiveObjectWithData:rideData];
        [pendingRideRate addObject:riteRate];
    }
    
    return pendingRideRate;
}

+ (void)removePendingRideRate{
#ifdef QA
    [defaults removeObjectForKey:userKey(kUnratedRides)];
    [defaults removeObjectForKey:userKey(kRideRatedPendingToUpload)];
    [defaults synchronize];
#endif
}

#pragma mark - Save Default Navigation App
+ (BOOL)hasDefaultNavigationApp{
    return [PersistenceManager hasKeyDefined:userKey(kDefaultNavigationApp)];
}

+ (void)saveDefaultNavigationApp:(NavigationApp)navigationApp{
    [defaults setInteger:navigationApp forKey:userKey(kDefaultNavigationApp)];
    [defaults synchronize];
}

+ (NavigationApp)cachedDefaultNavigationApp{
    return [defaults integerForKey:userKey(kDefaultNavigationApp)];
}

#pragma mark - Save Default Call Settings
+(BOOL)hasCallSetting{
    return [PersistenceManager hasKeyDefined:userKey(kCallKitSetting)];
}

+(void)saveCallSetting:(CallSetting)callSetting{
    [defaults setInteger:callSetting forKey:userKey(kCallKitSetting)];
    [defaults synchronize];
}

+(CallSetting)cachedCallSetting{
    return [defaults integerForKey:userKey(kCallKitSetting)];
}

#pragma mark - Save Last EventID
+(long long)cachedEventIDReceived {
    NSNumber *eventID = [defaults objectForKey:userKey(kLastEventID)];
    return eventID.longLongValue;
}
+(void)saveEventID:(long long)eventID {
    [defaults setObject:@(eventID) forKey:userKey(kLastEventID)];
}

#pragma mark - Location Settings Services

+(BOOL)hasLocationsSettings{
    return [defaults boolForKey:userKey(kLocationServicesSettings)];
}

+(void)saveLocationSettings:(BOOL)enabled{
    [defaults setBool:YES forKey:userKey(kLocationServicesSettings)];
    [defaults synchronize];
}


#pragma mark - Current City
+ (BOOL)hasCurrentCityTypeSaved {
    return [PersistenceManager hasKeyDefined:kCurrentCityType];
}

+ (void)saveCurrentCityType:(CityType)cityType {
    [defaults setInteger:cityType forKey:kCurrentCityType];
    [defaults synchronize];
}

+ (CityType)currentCityType {
    return (CityType)[defaults integerForKey:kCurrentCityType];
}

#pragma mark - Cached Config Global

+ (BOOL)hasConfigGlobal{
    return [self hasKeyDefined:kDefaultGlobalConfig];
}

+ (void)saveConfigGlobal:(ConfigGlobal*)config{
    [PersistenceManager archiveObject:config forFinalKey:kDefaultGlobalConfig];
}

+ (ConfigGlobal*)cachedConfigGlobal {
    return [PersistenceManager cachedObjectForFinalKey:kDefaultGlobalConfig];
}

#pragma mark - Device Token
+ (NSString *)cachedDeviceToken {
    return [defaults stringForKey:kRegisteredDeviceToken];
}

+ (void)saveRegisteredDeviceToken:(NSString *)deviceToken {
    if (deviceToken) {
        [defaults setObject:deviceToken forKey:kRegisteredDeviceToken];
    } else {
        [defaults removeObjectForKey:kRegisteredDeviceToken];
    }
}

+ (void)removeCachedDeviceToken {
    [self saveRegisteredDeviceToken:nil];
}

#pragma mark - Selected Car

+ (BOOL)hasPreviouslySelectedCar {
    return [PersistenceManager hasKeyDefined:userKey(kLastSelectedCar)];
}

+ (Car*)selectedCar {
    return (Car*)[PersistenceManager cachedObjectForKey:kLastSelectedCar];
}

+ (void)saveSelectedCar:(Car *)car {
    [PersistenceManager archiveObject:car forRawKey:kLastSelectedCar];
}

@end
