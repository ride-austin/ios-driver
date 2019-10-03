//
//  UIViewController+tripHistoryNavigation.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RASupportTopic;

@interface UIViewController (tripHistoryNavigation)

- (void)showNextScreenForTopic:(RASupportTopic *)supportTopic withRideId:(NSNumber *)rideId;

@end
