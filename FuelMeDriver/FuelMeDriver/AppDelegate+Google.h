//
//  AppDelegate+Google.h
//  RideDriver
//
//  Created by Roberto Abreu on 14/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <GooglePlaces/GMSPlacesClient.h>
@import FirebaseMessaging;

@interface AppDelegate (Google) <FIRMessagingDelegate>

- (void)setupGoogle;

@end
