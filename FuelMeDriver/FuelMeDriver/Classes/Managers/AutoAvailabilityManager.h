//
//  AutoAvailabilityManager.h
//  RideDriver
//
//  Created by Roberto Abreu on 8/27/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FeaturesService;
@interface AutoAvailabilityManager : NSObject
@property (weak, nonatomic, nullable) FeaturesService *featuresService;
+ (_Nonnull instancetype)sharedManager;

- (void)startMonitoringAvailability;
- (void)stopMonitoringAvailability;
- (void)goOfflineWithHandler;
@end
