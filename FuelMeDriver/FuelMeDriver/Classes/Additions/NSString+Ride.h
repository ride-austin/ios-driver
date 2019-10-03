//
//  NSString+Ride.h
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/8/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RideDriverEnums.h"

@interface NSString (Ride)

- (NSString*)md5;
- (NSString*)trim;
+ (BOOL)isEmpty:(NSString*)value;

+ (NSString*)stringWithPhotoType:(CarPhotoType)type;
+ (NSString*) driverStateToString: (DriverState) state;
+ (NSString*) stringFromDriverEventType:(DriverEventType)eventType;
@end
