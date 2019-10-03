//
//  RARatingManager.m
//  RideDriver
//
//  Created by Roberto Abreu on 11/8/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARatingManager.h"

#import "PersistenceManager.h"
#import "RARideAPI.h"

@implementation RARatingManager

+ (void)addRideRatedToCache:(RideRate *)rideRate {
    [PersistenceManager saveRideRate:rideRate];
}

+ (void)sendRideRatedCacheToServer {
    NSMutableArray *pendingListToUpload = [PersistenceManager pendingToUploadRideRate];
    for (RideRate *rideRate in pendingListToUpload) {
        [RARideAPI addRate:rideRate.rate toRideWithId:rideRate.rideId andCompletionBlock:^(NSError *error) {
            if (!error) {
                [PersistenceManager removeRideRate:rideRate];
            }
        }];
    }
}

@end
