//
//  RAActiveDriverPolling.h
//  RideDriver
//
//  Created by Roberto Abreu on 7/21/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAPollingManager.h"

@class RAActiveDriversCar;
@protocol RAActiveDriverPollingDelegate <NSObject>

- (void)showActiveDrivers:(NSArray<RAActiveDriversCar *> *)drivers;
- (void)clearActiveDrivers;

@end

@interface RAActiveDriverPolling : NSObject <RAPollingManager>

@property (weak, nonatomic) id<RAActiveDriverPollingDelegate> delegate;

- (instancetype)initWithDelegate:(id<RAActiveDriverPollingDelegate>)delegate;

@end
