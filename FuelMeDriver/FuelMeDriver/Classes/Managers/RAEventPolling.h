//
//  RAEventPolling.h
//  RideDriver
//
//  Created by Roberto Abreu on 7/21/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAEventDataModel.h"
#import "RAPollingManager.h"

@protocol RAEventPollingDelegate <NSObject>

- (void)handleInactiveEvent:(id<RAInactiveEventProtocol>)event;
- (void)handleHandShakeEvent:(id<RAHandShakeEventProtocol>)event;
- (void)handleRideRequestedEvent:(id<RARideRequestProtocol>)event;
- (void)handleRiderCancelledEvent:(RAEventDataModel *)event;
- (void)handleDriverCancelledEvent:(RAEventDataModel *)event;
- (void)handleAdminCancelledEvent:(RAEventDataModel *)event;
- (void)handleDestinationUpdated:(RAEventDataModel *)event;
- (void)handleRideUpgradeEvent:(RAEventDataModel<RARideUpgradeEventProtocol> *)event;
- (void)handleRiderLocationUpdatedEvent:(id<RARiderLocationUpdateProtocol>)event;
- (void)handleQueueEvent:(RAEventDataModel *)event;
- (void)handleQueuePenaltyEvent:(id<RAQueueEventPenaltyProtocol>)event;
- (void)handleSurgeAreaEvent:(RAEventDataModel *)event;
- (void)handleCategoryUpdateEvent:(id<RACarCategoryChangedEventProtocol>)event;
- (void)handleRiderCommentUpdatedEvent:(RAEventDataModel *)event;
- (void)handleCustomMessageEvent:(RAEventDataModel *)event;
- (void)handleStackedRideReassigned:(RAEventDataModel *)event;

@optional
- (void)didFinishPolling;

@end

@interface RAEventPolling : NSObject <RAPollingManager>

@property (weak, nonatomic) id<RAEventPollingDelegate> delegate;

- (instancetype)initWithDelegate:(id<RAEventPollingDelegate>)delegate;

@end
