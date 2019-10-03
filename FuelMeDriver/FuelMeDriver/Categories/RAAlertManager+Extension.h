//
//  RAAlertManager+Extension.h
//  RideDriver
//
//  Created by Robert on 14/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RideDriverEnums.h"
#import "RAAlertManager.h"

@class QueueEvent;
@interface RAAlertManager (Extension)

+ (UIAlertController*)showBackgroundRefreshStatusNotAvailableAlert;
+ (UIAlertController*)showAlertWithDisabledCategory:(NSArray<NSString *>*)disabledCategories andSource:(CarCategoryChangeSource)source;
+ (UIAlertController*)showAlertMarkedOfflineWithMessage:(NSString *)message;
+ (UIAlertController*)showCustomMessageWithTitle:(NSString*)title andMessage:(NSString*)message;
+ (void)showQueueAlert:(QueueEvent*)queueZone withMessage:(NSString*)message;
+ (UIAlertController*)showCancelledRideAlertWithMessage:(NSString*)message;
+ (void)showDidYouForgetToStartRideBackgroundLocalNotification;
+ (void)showNearDestinationRideBackgroundLocalNotification;
+ (void)showStartTripConfirmationWithAcceptBlock:(void(^)(void))completion;
+ (void)showEndTripConfirmationWithAcceptBlock:(void(^)(void))completion;
+ (void)showAutoOfflineLocalNotification:(NSString *)message; //_Nonnull
+ (void)showOnlineDriverDescription;

@end
