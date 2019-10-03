//
//  UIMutableUserNotificationAction+Initializer.m
//  RideDriver
//
//  Created by Robert on 14/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "UIMutableUserNotificationAction+Initializer.h"

@implementation UIMutableUserNotificationAction (Initializer)

+ (instancetype)actionWithIdentifier:(NSString*)identifier title:(NSString*)title activationMode:(UIUserNotificationActivationMode)activationMode destructive:(BOOL)destructive authenticationRequired:(BOOL)authenticationRequired {
    UIMutableUserNotificationAction *action = [UIMutableUserNotificationAction new];
    action.title = title;
    action.identifier = identifier;
    action.destructive = destructive;
    action.activationMode = activationMode;
    action.authenticationRequired = authenticationRequired;
    return action;
}

@end
