//
//  QueueViewController.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "QueueZone.h"

@protocol QueueUpdateDelegate <NSObject>

/**
 *  @brief called when queue events are received while QueueViewController is active
 */
- (void)queueUpdatedWithResponse:(NSDictionary * _Nonnull)response;

@end

@interface QueueViewController : BaseViewController <QueueUpdateDelegate>

@property (nonatomic, nonnull) QueueZone *queue;

@end
