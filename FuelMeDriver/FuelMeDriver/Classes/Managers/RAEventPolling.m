//
//  RAEventPolling.m
//  RideDriver
//
//  Created by Roberto Abreu on 7/21/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAEventPolling.h"

#import "ErrorReporter.h"
#import "PersistenceManager.h"
#import "RAEventDataModel.h"
#import "RAEventsAPI.h"
#import "RAAlertManager.h"


#define kIntervalLongPollingHadError 4.0

@interface RAEventPolling ()

@property (assign, nonatomic) BOOL isPollingInProgress;
@property (assign, nonatomic) BOOL shouldContinueLongPolling;
@property (nonatomic) long long cachedEventIDReceived;

@end

@implementation RAEventPolling

- (instancetype)initWithDelegate:(id<RAEventPollingDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _cachedEventIDReceived = [PersistenceManager cachedEventIDReceived];
    }
    return self;
}

- (void)start {
    
    if ([RASessionManager shared].isSignedIn == NO || self.isPollingInProgress) {
        return;
    }
    
    self.shouldContinueLongPolling = YES;
    self.isPollingInProgress = YES;
    __weak RAEventPolling *weakSelf = self;
    [RAEventsAPI getEventsWithLastReceivedEvent:@(self.cachedEventIDReceived)
                                CompletionBlock:^(NSArray<RAEventDataModel *> *events,
                                                  NSNumber *lastReceivedEventID,
                                                  NSError *error) {
        weakSelf.isPollingInProgress = NO;
        if (error) {
            [weakSelf handlePollingError:error];
        } else {
            weakSelf.cachedEventIDReceived = lastReceivedEventID.longLongValue;
            for (RAEventDataModel *event in events) {
                [weakSelf handleGenericEvent:event];
            }
        }
        
        if ([weakSelf.delegate respondsToSelector:@selector(didFinishPolling)]) {
            [weakSelf.delegate didFinishPolling];
        }
        
        if (weakSelf.shouldContinueLongPolling) {
            if (error) {
                [weakSelf performSelector:@selector(start) withObject:nil afterDelay:kIntervalLongPollingHadError];
            } else {
                [weakSelf start];
            }
        }
    }];
}

- (void)stop {
    self.shouldContinueLongPolling = NO;
}

#pragma mark - Handle Error

- (void)handlePollingError:(NSError*)error {
    switch (error.code) {
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
        case SERVERUnavailable:
            [ErrorReporter recordError:error withDomainName:error.code];
            [self showServerConnectivityLost];
            break;
        default:
            break;
    }
}

- (void)showServerConnectivityLost {
    dispatch_async(dispatch_get_main_queue(), ^{
        RAAlertOption *option = [RAAlertOption optionWithState:StateActive andShownOption:AvoidRecurring];
        [RAAlertManager showErrorWithAlertItem:@"We are unable to connect to server at this moment. Please try again later or Contact Support."
                                    andOptions:option];
    });
}

#pragma mark - Handle Events

- (void)handleGenericEvent:(RAEventDataModel *)event {
    
    switch (event.type) {
        case DriverInactive:
            [self.delegate handleInactiveEvent:event];
            break;
            
        case HandShake:
            [self.delegate handleHandShakeEvent:event];
            break;
            
        case RideRequested:
            [self.delegate handleRideRequestedEvent:event];
            break;
            
        case RiderCancelledRide:
            [self.delegate handleRiderCancelledEvent:event];
            break;
            
        case DriverCancelledRide:
            [self.delegate handleDriverCancelledEvent:event];
            break;
            
        case AdminCancelledRide:
            [self.delegate handleAdminCancelledEvent:event];
            break;
            
        case RideDestinationUpdated:
            [self.delegate handleDestinationUpdated:event];
            break;
            
        case RideUpgradeAccepted:
        case RideUpgradeRejected:
            [self.delegate handleRideUpgradeEvent:event];
            break;
            
        case RideStackedReassigned:
            [self.delegate handleStackedRideReassigned:event];
            break;
            
        case RiderLocationUpdated:
            [self.delegate handleRiderLocationUpdatedEvent:event];
            break;
            
        case RiderCommentUpdated:
            [self.delegate handleRiderCommentUpdatedEvent:event];
            break;
        
        case QueueEntering:
        case QueueUpdate:
        case QueueLeavingArea:
        case QueueLeavingInactive:
        case QueueLeavingInARide:
            [self.delegate handleQueueEvent:event];
            break;
            
        case QueueLeavingPenalty:
            [self.delegate handleQueuePenaltyEvent:event];
            break;
            
        case SurgeAreaChanged:
            [self.delegate handleSurgeAreaEvent:event];
            break;
            
        case CarCategoryChanged:
            [self.delegate handleCategoryUpdateEvent:event];
            break;
        
        case DriverTypeUpdate:
            [[RASessionManager shared] reloadCurrentDriverWithCompletion:nil];
            break;
            
        case CustomMessage:
            [self.delegate handleCustomMessageEvent:event];
            break;
        case RatingUpdated:
            //deprecated
            break;
        case InvalidEventType:
            //ride status
        case DriverAvailable:
        case DriverAssignedToRide:
        case DriverReachedRider:
        case DriverRiding:
        case NoAvailableDriverForRide:
        case RideCompleted:
        case RideActive:
            break;
    }

}

#pragma mark - LastReceivedEventID
- (void)setCachedEventIDReceived:(long long)cachedEventIDReceived {
    if (cachedEventIDReceived > _cachedEventIDReceived) {
        _cachedEventIDReceived = cachedEventIDReceived;
        [PersistenceManager saveEventID:cachedEventIDReceived];
    }
}

@end
