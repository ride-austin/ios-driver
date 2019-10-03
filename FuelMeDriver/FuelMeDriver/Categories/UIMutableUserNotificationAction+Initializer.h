//
//  UIMutableUserNotificationAction+Initializer.h
//  RideDriver
//
//  Created by Robert on 14/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMutableUserNotificationAction (Initializer)

+ (instancetype)actionWithIdentifier:(NSString*)identifier title:(NSString*)title activationMode:(UIUserNotificationActivationMode)activationMode destructive:(BOOL)destructive authenticationRequired:(BOOL)authenticationRequired;

@end
