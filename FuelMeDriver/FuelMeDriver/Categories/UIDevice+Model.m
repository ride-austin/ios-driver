//
//  UIDevice+Model.m
//  RideDriver
//
//  Created by Roberto Abreu on 9/10/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "UIDevice+Model.h"
#import <sys/utsname.h>

@implementation UIDevice (Model)

-(NSString *)modelType{
    return machineName();
}

NSString *machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *iOSDeviceModelsPath = [[NSBundle mainBundle] pathForResource:@"iOSDeviceModel" ofType:@"plist"];
    NSDictionary *iOSDevices = [NSDictionary dictionaryWithContentsOfFile:iOSDeviceModelsPath];
    
    NSString* deviceModel = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    
    return [iOSDevices valueForKey:deviceModel];
}

@end
