//
//  RARideCacheManager.m
//  RideDriver
//
//  Created by Kitos on 6/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RARideCacheManager.h"

#import "ErrorReporter.h"
#import "NetworkManager.h"
#import "PersistenceManager.h"
#import "RARideAPI.h"
#import "RARideCache.h"
#import "RideDriverConstants.h"

NSString * const kRIDE_IS_ALREADY_ENDED_OR_CANCELED = @"\"Ride is already ended or canceled.\"";
NSString * const kRIDE_NOT_FOUND = @"\"Ride not found\"";

typedef void(^RAFlushCompletionBlock)(NSError *error);

@interface RARideCacheManager ()

@property (nonatomic) BOOL isFlushing;
@property (nonatomic, strong) NSMutableArray<RARideCache *> *rideCaches;

@end

@implementation RARideCacheManager

#pragma mark - Lifecycle

+ (RARideCacheManager *)sharedManager {
    static RARideCacheManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RARideCacheManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self addObservers];
        _rideCaches = [self loadRideCachesFromDisk];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observers

- (void)addObservers {
    __weak RARideCacheManager *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        if ([weakSelf hasCacheToFlush]) {
            [weakSelf flushAllRideCacheWithCompletion:nil];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNetworkReachabilityStatusChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        NSNumber *statusNumber = (NSNumber *)notification.object;
        AFRKNetworkReachabilityStatus status = [statusNumber intValue];
        [weakSelf handleReachabilityStatusChange:status];
    }];
   
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        [weakSelf saveRideCachesToDisk];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        [weakSelf saveRideCachesToDisk];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
        [weakSelf saveRideCachesToDisk];
    }];
}

- (void)handleReachabilityStatusChange:(AFRKNetworkReachabilityStatus)status {
    switch (status) {
        case AFRKNetworkReachabilityStatusNotReachable: {
            break;
        }
        case AFRKNetworkReachabilityStatusReachableViaWiFi:
        case AFRKNetworkReachabilityStatusReachableViaWWAN: {
            [self flushAllRideCacheWithCompletion:nil];
            break;
        }
        case AFRKNetworkReachabilityStatusUnknown: {
            break;
        }
    }
}

#pragma mark - Persistence

- (RARideCache *)rideCacheWithId:(NSString *)rideId {
    for (RARideCache *rideCache in self.rideCaches) {
        if ([rideCache.rideID isEqualToString:rideId]) {
            return rideCache;
        }
    }
    return nil;
}

- (void)cleanAllCaches {
    [self.rideCaches removeAllObjects];
    [self saveRideCachesToDisk];
}

- (void)cleanRideCache:(RARideCache *)rideCache {
    @synchronized(self) {
        [rideCache cleanCache];
        [self.rideCaches removeObject:rideCache];
        [self saveRideCachesToDisk];
    }
}

- (NSMutableArray<RARideCache *> *)loadRideCachesFromDisk {
    NSMutableArray <RARideCache *> *rideCaches = [PersistenceManager rideCaches];
    if (!rideCaches) {
        rideCaches = [NSMutableArray array];
    }
    return rideCaches;
}

- (void)saveRideCachesToDisk {
    [PersistenceManager saveRideCaches:self.rideCaches];
}

#pragma mark - Cache Events

- (void)initCacheForRideWithId:(NSString *)rideId {
    @synchronized(self) {
        RARideCache *rideCache = [self rideCacheWithId:rideId];
        if (!rideCache) {
            rideCache = [RARideCache rideCacheForRideID:rideId];
            [self.rideCaches addObject:rideCache];
            [self saveRideCachesToDisk];
        }
    }
}

- (void)endCacheForRideWithId:(NSString *)rideId {
    RARideCache *rideCache = [self rideCacheWithId:rideId];
    if (rideCache) {
        [self cleanRideCache:rideCache];
    }
}

- (void)driverReachedRiderForRideWithId:(NSString *)rideId {
    RARideCache *rideCache = [self rideCacheWithId:rideId];
    if (rideCache && ![self hasReachedInCacheForRideWithId:rideId]) {
        RADriverReachedRideEvent *event = [[RADriverReachedRideEvent alloc] initWithRideID:rideCache.rideID];
        [rideCache setReachedPickup:YES];
        [self addEvent:event toRideCache:rideCache];
    }
}

- (void)driverStartedRideWithId:(NSString *)rideId {
    RARideCache *rideCache = [self rideCacheWithId:rideId];
    if (rideCache && ![self hasStartedInCacheForRideWithId:rideId]) {
        RARideStartedRideEvent *event = [[RARideStartedRideEvent alloc] initWithRideID:rideCache.rideID];
        [rideCache setTripStarted:YES];
        [self addEvent:event toRideCache:rideCache];
    }
}

- (void)updateDriverLocationForRideWithId:(NSString *)rideId coordinate:(CLLocationCoordinate2D)coordinate speed:(CLLocationSpeed)speed heading:(CLLocationDirection)heading andCourse:(CLLocationDirection)course {
    RAUpdateLocationRideEvent *event = [[RAUpdateLocationRideEvent alloc] initWithRideID:rideId];
    event.latitude = coordinate.latitude;
    event.longitude = coordinate.longitude;
    event.speed = speed;
    event.heading = heading;
    event.course = course;
    @synchronized (self) {
        RARideCache *rideCache = [self rideCacheWithId:rideId];
        if (rideCache && rideCache.tripStarted && !rideCache.completed) {
            [self addEvent:event toRideCache:rideCache];
        }
    }
}

- (void)driverEndRideWithId:(NSString *)rideId atLocation:(CLLocationCoordinate2D)coordinate {
    RARideCache *rideCache = [self rideCacheWithId:rideId];
    if (rideCache && ![self hasCompletedInCacheForRideWithId:rideId]) {
        RARideEndedRideEvent *event = [[RARideEndedRideEvent alloc] initWithRideID:rideCache.rideID];
        event.latitude = coordinate.latitude;
        event.longitude = coordinate.longitude;
        [rideCache setCompleted:YES];
        [self addEvent:event toRideCache:rideCache];
    }
}

- (void)addEvent:(RARideEvent *)rideEvent toRideCache:(RARideCache *)rideCache {
    @synchronized (self) {
        [rideCache addRideEvent:rideEvent];
        [self saveRideCachesToDisk];
    }
}

#pragma mark - Cache Events Helper

- (BOOL)hasCacheToFlush {
    return [self.rideCaches count] > 0;
}

- (void)markRideAsReachedWithId:(NSString *)rideId {
    @synchronized (self) {
        RARideCache *rideCache = [self rideCacheWithId:rideId];
        if (rideCache) {
            [rideCache setReachedPickup:YES];
            [self saveRideCachesToDisk];
        }
    }
}

- (void)markRideAsStartedWithId:(NSString *)rideId {
    @synchronized (self) {
        RARideCache *rideCache = [self rideCacheWithId:rideId];
        if (rideCache) {
            [rideCache setTripStarted:YES];
            [self saveRideCachesToDisk];
        }
    }
}

- (void)markRideAsCompletedWithId:(NSString *)rideId {
    @synchronized (self) {
        RARideCache *rideCache = [self rideCacheWithId:rideId];
        if (rideCache) {
            [rideCache setCompleted:YES];
            [self saveRideCachesToDisk];
        }
    }
}

- (BOOL)hasReachedInCacheForRideWithId:(NSString *)rideId {
    return [self hasEventWithType:[RADriverReachedRideEvent class] forRideWithId:rideId];
}

- (BOOL)hasStartedInCacheForRideWithId:(NSString *)rideId {
    return [self hasEventWithType:[RARideStartedRideEvent class] forRideWithId:rideId];
}

- (BOOL)hasCompletedInCacheForRideWithId:(NSString *)rideId {
    return [self hasEventWithType:[RARideEndedRideEvent class] forRideWithId:rideId];
}

- (BOOL)hasEventWithType:(Class)eventType forRideWithId:(NSString *)rideId {
    RARideCache *rideCache = [self rideCacheWithId:rideId];
    for (RARideEvent *event in rideCache.events.allValues) {
        if ([event isKindOfClass:eventType]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasCacheForRideWithId:(NSString *)rideId {
    RARideCache *rideCache = [self rideCacheWithId:rideId];
    return rideCache && [rideCache hasData];
}

- (DriverState)driverStateBasedOnRideCacheWithId:(NSString *)rideId {
    RARideCache *rideCache = [self rideCacheWithId:rideId];
    return rideCache ? [rideCache driverState] : InvalidDriverState;
}

#pragma mark - Flush Events

- (void)flushAllRideCacheWithCompletion:(void (^)(BOOL))completion {
    __weak __typeof__(self) weakself = self;
    
    if (self.isFlushing || ![self hasCacheToFlush]) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    self.isFlushing = YES;
    
    if (self.delegate) {
        [self.delegate willFlushRideCacheData];
    }
    
    NSMutableArray *operatingCaches = self.rideCaches.mutableCopy;
    [self submitCacheArray:operatingCaches withCompletion:^(BOOL success) {
        weakself.isFlushing = NO;
        
        if (weakself.delegate) {
            [weakself.delegate didFlushRideCacheDataSuccessfully:success];
        }
        
        if (completion) {
            completion(success);
        }
    }];
}


/**
 wait for each item in cacheArray to upload before uploading the next item.
 If one fails, the next ones shouldn't continue
 */
- (void)submitCacheArray:(NSMutableArray *)cacheArray withCompletion:(void(^)(BOOL success))completion {
    if (cacheArray.count == 0) {
        completion(YES);
    } else {
        [self submitRideCache:cacheArray.firstObject withCompletion:^(BOOL success) {
            if (success) {
                if (cacheArray.count == 1) {
                    completion(YES);
                } else {
                    [cacheArray removeObjectAtIndex:0];
                    [self submitCacheArray:cacheArray withCompletion:completion];
                }
            } else {
                completion(NO);
            }
        }];
    }
}
- (void)submitRideCache:(RARideCache *)rideCache withCompletion:(void(^)(BOOL))completion {
    __weak RARideCacheManager *weakSelf = self;
    if ([rideCache hasData]) {
        [RARideAPI postEvents:rideCache.jsonObject withCompletion:^(NSError *error) {
            if (error) {
                NSString *errorMessage = error.localizedRecoverySuggestion;
                BOOL serverNotAcceptEvents = [errorMessage isEqualToString:kRIDE_IS_ALREADY_ENDED_OR_CANCELED] || [errorMessage isEqualToString:kRIDE_NOT_FOUND];
                if (serverNotAcceptEvents) {
                    [weakSelf cleanRideCache:rideCache];
                }
                completion(serverNotAcceptEvents);
            } else {
                if ([rideCache wasCompleted]) {
                    [weakSelf rideCompletedFromRideCache:rideCache];
                } else {
                    [rideCache cleanCache];
                    [weakSelf saveRideCachesToDisk];
                }
                completion(YES);
            }
        }];
    } else {
        [RARideAPI isRideActiveWithId:rideCache.rideID andCompletion:^(BOOL isRideActive, NSError *error) {
            if (!error && !isRideActive) {
                [weakSelf cleanRideCache:rideCache];
            }
            completion(YES);
        }];
    }
}

- (void)rideCompletedFromRideCache:(RARideCache *)rideCache {
    NSString *rideId = rideCache.rideID;
    [RARideAPI getRideWithId:rideId andCompletion:^(RARideDataModel *ride, NSError *error) {
        if (ride && [ride.status isEqualToString:@"COMPLETED"]) {
            [PersistenceManager saveUnratedRideData:ride];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUnratedRideAddedFromRideCache object:nil];
        }
    }];
    [self cleanRideCache:rideCache];
}

@end

@implementation RARideCacheManager (Testing)

- (void)removeCache {
#ifdef AUTOMATION
    [self cleanAllCaches];
#endif
}

@end
