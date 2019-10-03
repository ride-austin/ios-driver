//
//  UIDevice+Unique.m
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "UIDevice+Unique.h"

#import <SAMKeychain/SAMKeychain.h>

@implementation UIDevice (Unique)

-(NSString *)uniqueDeviceIdentifier{
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SAMKeychain passwordForService:appName account:@"RideAustin"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[self identifierForVendor] UUIDString];
        [SAMKeychain setPassword:strApplicationUUID forService:appName account:@"RideAustin"];
    }
    
    return strApplicationUUID;
}

@end
