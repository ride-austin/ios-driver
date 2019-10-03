//
//  RAAlertConstant.h
//  Ride
//
//  Created by Roberto Abreu on 15/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//


#ifndef RAAlertConstant_h
#define RAAlertConstant_h
/**
 *@Brief: Show the alert base on the state of the app.
 */
typedef NS_ENUM(NSUInteger, RAAlertState) {
    StateAll,
    StateActive,
    StateBackground,
};

/**
 *@Brief
 * None ~ Just show the alert if there isn't one present
 * Overlap ~ Show the alert on top of any alert
 * AllowNetworkError ~ Allow Network error to be shown (statusCode = 0)
 * ReplaceContent ~ If an alert is shown, just replace the content
 * Block ~ Doesn't show button for this alert
 * AvoidRecurring ~ error will not show before kErrorMinimumTimeToShow
 * AvoidCredentialError ~ This will avoid 401 message error
 * The options can be mixed. Like (Overlap | AllowNetworkError)
 */
typedef NS_OPTIONS(NSUInteger, RAAlertShownOption) {
    None = 1 << 0,
    Overlap = 1 << 1,
    AllowNetworkError = 1 << 2,
    ReplaceContent = 1 << 3,
    Block = 1 << 4,
    AvoidRecurring = 1 << 5,
    AvoidCredentialError = 1 << 6
};

static NSString *const kDefaultErrorAlertTitle = @"Oops";

#endif /* RAAlertConstant_h */
