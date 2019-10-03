//
//  RAAlertManager+Extension.m
//  RideDriver
//
//  Created by Robert on 14/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAAlertManager+Extension.h"
#import "PopupManagerDefines.h"
#import "QueueEvent.h"
#import "DriverManager.h"
#import "ConfigurationManager.h"
#import "PersistenceManager.h"
#import "RASessionManager.h"
#import "RACarCategoryDataModel+Collections.h"
@implementation RAAlertManager (Extension)

+ (UIAlertController *)showBackgroundRefreshStatusNotAvailableAlert {
    UIBackgroundRefreshStatus status = [[UIApplication sharedApplication] backgroundRefreshStatus];
    
    if (status == UIBackgroundRefreshStatusAvailable) {
        return nil;
    }
    
    NSString *message = @"";
    if (status == UIBackgroundRefreshStatusDenied) {
        message = @"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh";
    } else {
        message = @"The functions of this app are limited because the Background App Refresh is disabled.";
    }
    
    return [RAAlertManager showAlertWithTitle:@"" message:message options:[RAAlertOption optionWithShownOption:Overlap]];
}

+ (UIAlertController *)showAlertWithDisabledCategory:(NSArray<NSString *> *)disabledCategories andSource:(CarCategoryChangeSource)source {
    NSMutableString *categoriesDisabledName = [NSMutableString stringWithString:@""];
    NSArray<RACarCategoryDataModel *> *disabledCarCategories = disabledCategories.stringToCarCategories;
    for (int i = 0; i < disabledCarCategories.count ; i++) {
        RACarCategoryDataModel *disabledCategory = disabledCarCategories[i];
        if (i != 0) {
            [categoriesDisabledName appendString:@","];
        }
        [categoriesDisabledName appendString:disabledCategory.title];
    }
    
    BOOL isPlural = disabledCategories.count > 1;
    NSString *categoryLiteral       = isPlural ? @"Categories" : @"Category";
    NSString *thisCategoryLiteral   = isPlural ? @"these categories" : @"this category";
    NSString *wasDisabled           = isPlural ? @"were disabled"    : @"was disabled";
    NSString *title = [NSString stringWithFormat:@"Car %@ Disabled!",categoryLiteral];
    NSString *body  = [NSString stringWithFormat:@"Car %@ <%@> %@",
                       categoryLiteral.lowercaseString,
                       categoriesDisabledName,
                       wasDisabled];
    NSString *message = @"";
    
    
    switch (source) {
        case AdminEdit:
            body = [NSString stringWithFormat:@"%@ by Admin.",body];
            break;
        case MissedRequest:
            body = [NSString stringWithFormat:@"%@ due to many consecutive missed requests.",body];
            message = [NSString stringWithFormat:@"%@\nIf you want to receive requests in %@, enable it in MENU > RIDE REQUEST TYPE.", body, thisCategoryLiteral.lowercaseString];
            break;
        case Unknown:
            DBLog(@"Unknown Category source changed");
            break;
    }
    
    if (IS_EMPTY(message)) {
        message = body;
    }
    
    //Display only in background
    [RAAlertManager showLocalNotificationWithTitle:title message:message andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateBackground andAlertActionTitle:nil]];
    
    //Show alert in all states
    return [RAAlertManager showAlertWithTitle:title message:message];
}

+ (UIAlertController *)showAlertMarkedOfflineWithMessage:(NSString *)message {
    NSString *title   = kDefaultErrorAlertTitle;
    if ([message isKindOfClass:[NSString class]] == NO) {
        message = @"You have been marked as offline due to inactivity or excessive consecutive missed ride requests.\nPlease go online again for additional requests.";
    }
    
    [RAAlertManager showLocalNotificationWithTitle:title message:message andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateBackground andAlertActionTitle:nil]];
    
    return [RAAlertManager showAlertWithTitle:title message:message];
}

+ (UIAlertController *)showCustomMessageWithTitle:(NSString *)title andMessage:(NSString *)message {
    [RAAlertManager showLocalNotificationWithTitle:title message:message andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateAll andAlertActionTitle:@"Ok"]];
    return [RAAlertManager showAlertWithTitle:title message:message options:[RAAlertOption optionWithState:StateBackground]];
}

+ (void)showQueueAlert:(QueueEvent *)queueEvent withMessage:(NSString *)message {
    [RAAlertManager showLocalNotificationWithTitle:queueEvent.alertTitle message:message andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateAll andAlertActionTitle:@"Ok"]];
}

+ (UIAlertController *)showCancelledRideAlertWithMessage:(NSString *)message {
    NSString *title = @"TRIP WAS CANCELLED";
    [RAAlertManager showLocalNotificationWithTitle:title message:message andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateAll andAlertActionTitle:nil]];
    return [RAAlertManager showAlertWithTitle:title message:message options:[RAAlertOption optionWithState:StateBackground]];
}

+ (void)showDidYouForgetToStartRideBackgroundLocalNotification {
    RAAlertNotificationOption *option = [[RAAlertNotificationOption alloc] initWithState:StateBackground withAlertActionTitle:nil categoryIdentifier:kLocalNotificationAwayFromPickupID requestIdentifier:kLocalNotificationAwayFromPickupReqID andUserInfo:nil];
    [RAAlertManager showLocalNotificationWithTitle:@"Start Ride" message:@"Did you forget to start the ride?" andNotificationOption:option];
}

+ (void)showNearDestinationRideBackgroundLocalNotification {
    RAAlertNotificationOption *option = [[RAAlertNotificationOption alloc] initWithState:StateBackground withAlertActionTitle:nil categoryIdentifier:kLocalNotificationNearDestinationID requestIdentifier:kLocalNotificationNearDestinationReqID andUserInfo:nil];
    [RAAlertManager showLocalNotificationWithTitle:@"Arriving" message:@"You have arrived at the destination. End trip?" andNotificationOption:option];
}

+ (void)showConfirmationAlertWithTitle:(NSString*)title
                           andMessage:(NSString*)message
                    withRequiredState:(DriverState)requiredDriverState
                         acceptedBlock:(void(^)(void))acceptedBlock{
    
    RAAlertOption *option = [RAAlertOption optionWithState:StateActive];
    [option addAction:[RAAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [option addAction:[RAAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nullable action) {
        if ([DriverManager shared].driverState == requiredDriverState) {
            acceptedBlock();
        }
    }]];
    
    [RAAlertManager showAlertWithTitle:title message:message options:option];
}

+ (void)showStartTripConfirmationWithAcceptBlock:(void(^)(void))completion {
    [self showConfirmationAlertWithTitle:@"Start Ride" andMessage:@"Are you sure you want to start the trip?" withRequiredState:ArrivingToPickUpDriverState acceptedBlock:completion];
}

+ (void)showEndTripConfirmationWithAcceptBlock:(void(^)(void))completion {
    [self showConfirmationAlertWithTitle:@"End Ride" andMessage:@"Are you sure you want to end the trip?" withRequiredState:OnTripDriverState acceptedBlock:completion];
}

+ (void)showAutoOfflineLocalNotification:(NSString *)message {
    [self showLocalNotificationWithTitle:@"" message:message andNotificationOption:[RAAlertNotificationOption notificationOptionWithState:StateBackground andCategoryIdentifier:kLocalNotificationOfflineId]];
}

+ (void)showOnlineDriverDescription {
    RASessionDataModel *session = [RASessionManager shared].currentSession;
    RADriverDataModel *currentDriver = session.driver;
    Car *selectedCar = currentDriver.selectedCar;
    NSString *title = [NSString stringWithFormat:@"%@ %@ is online", selectedCar.make, selectedCar.model];
    
    ConfigurationManager *configManager = [ConfigurationManager shared];
    BOOL canReceiveFemaleDriver = [configManager.global availableFemaleDriverModeForDriver:currentDriver];

    NSArray<NSString *> *userCarTypes = session.userCarTypes;
    NSString *userCarTypesTitles = userCarTypes.stringToCarCategories.titlesString;
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:@"You are set to receive\n\n"];
    
    switch ([RASessionManager shared].currentSession.driverTypeFilter) {
        case DriverTypeFemaleDriver:
            [message appendString:[NSString stringWithFormat:@"%@\nFemale Driver Requests ONLY\n\nTo receive requests from all genders, go to Ride Request Type", userCarTypesTitles]];
            break;
        case DriverTypeUnspecified:
            if (canReceiveFemaleDriver) {
                [message appendString:userCarTypesTitles];
                NSArray<NSString *> *availableInCategories = configManager.global.driverTypeOnlyWomenMode.availableInCategories;
                if (availableInCategories) {
                    NSSet *femaleDriverModeEligibleCategories = [NSSet setWithArray:availableInCategories];
                    NSMutableSet *availableCategories = [NSMutableSet setWithArray:userCarTypes];
                    [availableCategories intersectSet:femaleDriverModeEligibleCategories];
                    [message appendString:[NSString stringWithFormat:@"\nand\n%@\nfemale driver requests", availableCategories.stringToTitlesString]];
                }
            } else {
                [message appendString:userCarTypesTitles];
            }
            break;
        case DriverTypeDirectConnect:
            [message appendString:[NSString stringWithFormat:@"%@\n Direct Connect Requests ONLY\n\nTo remove this filter, go to Ride Request Type", userCarTypesTitles]];
            break;
    }
    
    [self showAlertWithTitle:title message:message];
}

@end
