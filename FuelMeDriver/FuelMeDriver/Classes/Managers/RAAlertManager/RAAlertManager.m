//
//  RAAlertManager.m
//  Ride
//
//  Created by Roberto Abreu on 15/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAAlertManager.h"
#import <UserNotifications/UserNotifications.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)
#define IS_EMPTY(value) (((value) == (id)[NSNull null] || (value) == nil || ([(value) isKindOfClass:[NSString class]] && ([(id)(value) isEqualToString:@""] || [(id)(value) isEqualToString:@"<null>"]))) ? YES : NO)

static UIAlertController *alertController = nil;
static UIAlertController *errorAlertController = nil;

@interface RAAlertManager ()

+ (void)addActions:(NSArray<RAAlertAction*>*)actionButtons
           toAlert:(UIAlertController*)alertController;

@end

@interface RAAlertManager (TimeoutErrorManagement)

+(BOOL)isTimeoutError:(NSInteger)statusCode;
+(BOOL)canShowTimeoutError;
+(NSString*)timeOutUserFriendlyMessage;

@end

@interface RAAlertManager (ErrorManagement)

+(BOOL)canShowError:(NSInteger)errorCode;

@end

@interface RAAlertManager (Cache)

+(void)saveLastTimeoutErrorDate:(NSDate *)date;
+(NSDate *)getLastTimeoutErrorDate;

+(void)saveError:(NSInteger)errorCode lastDateShown:(NSDate*)date;
+(NSDate*)getLastDateShownForError:(NSInteger)errorCode;
+(NSString *)getKeyForError:(NSInteger)errorCode;

@end

@implementation RAAlertManager

#pragma mark - Show Alert
+ (UIAlertController*)showAlertWithTitle:(NSString*)title message:(NSString*)message {
    return [self showAlertWithTitle:title message:message options:[RAAlertOption optionWithTitle:title]];
}

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message options:(RAAlertOption *)option {
    
    RAAlertState state = StateAll;
    RAAlertShownOption shownOptions = None;
    NSString *alertTitle = title;
    NSArray<RAAlertAction *> *actionButtons = nil;
    
    if (option) {
        alertTitle = option.title ? option.title : title;
        state = option.state;
        shownOptions = option.shownOption;
        actionButtons = [option.actions copy];
    }
    
    if ([self canShowAlertWithState:state]) {
        if ((shownOptions & Overlap)) {
            
            UIAlertController *overlapController = [UIAlertController alertControllerWithTitle:alertTitle message:message preferredStyle:UIAlertControllerStyleAlert];
            
            //If the alert is block, should not add buttons
            if (!(shownOptions & Block)) {
                [RAAlertManager addActions:actionButtons toAlert:overlapController];
            }
            
            [overlapController show];
            return overlapController;
        }
        
        if (!alertController) {
            alertController = [UIAlertController alertControllerWithTitle:alertTitle message:message preferredStyle:UIAlertControllerStyleAlert];
        }
        
        if ((shownOptions & ReplaceContent)) {
            alertController.title = title;
            alertController.message = message;
            return alertController;
        }
        
        if (![alertController isShowing]) {
            if (!(shownOptions & Block)) {
                [RAAlertManager addActions:actionButtons toAlert:alertController];
            }
            
            [alertController show];
            return alertController;
        }
    }
    
    return nil;
}

#pragma mark - Show Errors

+ (UIAlertController*)showErrorWithAlertItem:(id<RAAlertItem>)alertItem andOptions:(RAAlertOption*)option {
    
    BOOL isTimeoutError = [RAAlertManager isTimeoutError:[alertItem statusCodeAlert]];
    
    RAAlertState state = StateAll;
    RAAlertShownOption shownOptions = None;
    NSString *title = kDefaultErrorAlertTitle;
    NSString *message = isTimeoutError ? [RAAlertManager timeOutUserFriendlyMessage] : [alertItem messageAlert];
    NSArray *actionButtons = nil;
    
    if (option) {
        title = option.title ? option.title : title;
        state = option.state;
        shownOptions = option.shownOption;
        actionButtons = [option.actions copy];
    }
    
    if (IS_EMPTY(message)) {
        message = @"Something went wrong.\nKeep calm and try again later.";
    }
    
    if (![self isAllowCredentialErrorWithAlertItem:alertItem withOption:shownOptions]) {
        return nil;
    }
    
    BOOL isNetworkErrorAllow = [self isAllowNetworkErrorWithAlertItem:alertItem withOption:shownOptions];
    if (isTimeoutError) {
        isNetworkErrorAllow = isNetworkErrorAllow && [RAAlertManager canShowTimeoutError];
        [RAAlertManager saveLastTimeoutErrorDate:[NSDate date]];
    }
    
    if ([self canShowAlertWithState:state] && isNetworkErrorAllow) {
        
        //
        //  AvoidRecurring errors if errorCode has been displayed within kErrorMinimumTimeToShow
        //
        if (shownOptions & AvoidRecurring) {
            NSInteger errorCode = [alertItem statusCodeAlert];
            if ([RAAlertManager canShowError:errorCode]) {
                [RAAlertManager saveError:errorCode lastDateShown:[NSDate date]];
            } else {
                return nil;
            }
        }
        
        if ((shownOptions & Overlap)) {
            UIAlertController *overlapController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            
            //If the alert is block, should not add buttons
            if (!(shownOptions & Block)) {
                [RAAlertManager addActions:actionButtons toAlert:overlapController];
            }
            
            [overlapController show];
            return overlapController;
        }
        
        if (!errorAlertController) {
            errorAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        }
        
        if ((shownOptions & ReplaceContent)) {
            errorAlertController.title = title;
            errorAlertController.message = message;
            return errorAlertController;
        }
        
        if (![errorAlertController isShowing]) {
            
            if (!(shownOptions & Block)) {
                [RAAlertManager addActions:actionButtons toAlert:errorAlertController];
            }
            
            [errorAlertController show];
            return errorAlertController;
        }
            
    }
    
    return nil;
}

#pragma mark - Local Notifications

+ (void)showLocalNotificationWithTitle:(NSString *)title message:(NSString *)message andNotificationOption:(RAAlertNotificationOption *__nonnull)option {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!(option && [RAAlertManager canShowAlertWithState:option.state])) {
            return;
        }
        
        //iOS10 Local Notifications with NotificationCenter
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) ) {
            
            //clear all pending notifications
            [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
            
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = title;
            content.body = message;
            content.sound = [UNNotificationSound soundNamed:@"RA-Alert.caf"];
            
            if (option) {
                content.categoryIdentifier = option.categoryIdentifier;
            }
            
            //trigger notification with interval
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                          triggerWithTimeInterval:1.f repeats:NO];
            
            NSString *requestIdentifier = option.requestIdentifier ? option.requestIdentifier : [[NSDate date] description];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
            
            //schedule localNotification
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"Location Notification Added: %@ ", request.identifier);
                }
            }];
            
        } else {
            
            //iOS9/8 Local Notifications
            //clear all local notifications
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            UILocalNotification *localNotification = [UILocalNotification new];
            localNotification.soundName = @"RA-Alert.caf";
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
                localNotification.alertTitle = title;
            }
            
            localNotification.alertBody = message;
            
            if (option) {
                localNotification.hasAction = (option.alertAction != nil);
                localNotification.alertAction = option.alertAction;
                localNotification.category = option.categoryIdentifier;
            }
            
            localNotification.repeatInterval = 0;
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    });
    
}

#pragma mark - Helpers

+ (BOOL)canShowAlertWithState:(RAAlertState)state{
    switch (state) {
        case StateBackground:{
            return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
        }
        case StateActive:{
            return [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
        }
        default:
            return YES;
    }
}

+ (BOOL)isAllowCredentialErrorWithAlertItem:(id<RAAlertItem>)alertItem withOption:(RAAlertShownOption)shownOptions {
    NSInteger statusCode = [alertItem statusCodeAlert];
    return (statusCode != 401) || (!(shownOptions & AvoidCredentialError) && statusCode == 401);
}

+ (BOOL)isAllowNetworkErrorWithAlertItem:(id<RAAlertItem>)alertItem withOption:(RAAlertShownOption)shownOptions{
    NSInteger statusCode = [alertItem statusCodeAlert];
    return (statusCode != 0 && statusCode != NSURLErrorNotConnectedToInternet && statusCode != 200) || (shownOptions & AllowNetworkError);
}

+ (void)addActions:(NSArray<RAAlertAction*>*)actionButtons toAlert:(UIAlertController*)alertCtrl {
    if (actionButtons.count > 0) {
        for (RAAlertAction* actionBtn in actionButtons) {
            [alertCtrl addAction:[UIAlertAction actionWithTitle:actionBtn.title style:actionBtn.style handler:^(UIAlertAction * _Nonnull action) {
                if (actionBtn.handler) {
                    actionBtn.handler(action);
                }
                if (alertCtrl == errorAlertController) {
                    errorAlertController = nil;
                }
                
                if (alertCtrl == alertController) {
                    alertController = nil;
                }
            }]];
        }
    } else {
        NSPredicate *findCancelAction = [NSPredicate predicateWithBlock:^BOOL(UIAlertAction   * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return evaluatedObject.style == UIAlertActionStyleCancel;
        }];
        NSArray *cancelActions = [alertCtrl.actions filteredArrayUsingPredicate:findCancelAction];
        BOOL canSafelyAddCancelButton = cancelActions.count == 0;
        if (canSafelyAddCancelButton) {
            [alertCtrl addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (alertCtrl == errorAlertController) {
                    errorAlertController = nil;
                }
                
                if (alertCtrl == alertController) {
                    alertController = nil;
                }
            }]];
        }
    }
}

#pragma mark - Helper Test

+ (void)resetAlerts {
    alertController = nil;
    errorAlertController = nil;
}

@end

#pragma mark - Timeout Error Management

static NSTimeInterval const kTimeoutMinimumTimeToShow = 60*2;   //2 minutes. Timeouts come after 60 seconds, and retries would be after 2 seconds more (often), so 2 minutes should be enough.

@implementation RAAlertManager (TimeoutErrorManagement)

+(BOOL)isTimeoutError:(NSInteger)statusCode{
    return statusCode == NSURLErrorTimedOut;
}

+(BOOL)canShowTimeoutError{
    BOOL show = YES;
    NSDate *lastTimeoutDate = [self getLastTimeoutErrorDate];
    if (lastTimeoutDate) {
        NSDate *today = [NSDate date];
        NSTimeInterval ti = [today timeIntervalSinceDate:lastTimeoutDate];
        show = (ti > kTimeoutMinimumTimeToShow);
    }
    return show;
}

+(NSString *)timeOutUserFriendlyMessage{
    return  @"You appear to have a poor connection. Keep calm and try again later.";
}

@end

#pragma mark - Error Management

static NSTimeInterval const kErrorMinimumTimeToShow = 60*2; // 2 minutes should be enough to show recurrent error.

@implementation RAAlertManager (ErrorManagement)

+(BOOL)canShowError:(NSInteger)errorCode{
    BOOL show = YES;
    NSDate *lastTimeoutDate = [self getLastDateShownForError:errorCode];
    if (lastTimeoutDate) {
        NSDate *today = [NSDate date];
        NSTimeInterval ti = [today timeIntervalSinceDate:lastTimeoutDate];
        show = (ti > kErrorMinimumTimeToShow);
    }
    return show;
}

@end

#pragma mark - Cache

static NSString *const kLastTimeoutErrorDateKey = @"kLastTimeoutErrorDateKey";
static NSString *const kLastErrorDateKey = @"kLastErrorDateKey";

@implementation RAAlertManager (Cache)

+(void)saveLastTimeoutErrorDate:(NSDate *)date{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastTimeoutErrorDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDate *)getLastTimeoutErrorDate{
    NSDate *lastTimeoutErrorDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastTimeoutErrorDateKey];
    if ([lastTimeoutErrorDate isKindOfClass:[NSDate class]]) {
        return lastTimeoutErrorDate;
    } else {
        return nil;
    }
}

+(void)saveError:(NSInteger)errorCode lastDateShown:(NSDate *)date{
    NSString *key = [self getKeyForError:errorCode];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDate *)getLastDateShownForError:(NSInteger)errorCode{
    NSString *key = [self getKeyForError:errorCode];
    return (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(NSString *)getKeyForError:(NSInteger)errorCode{
    return [NSString stringWithFormat:@"%@[%ld]",kLastErrorDateKey,(long)errorCode];
}

@end
