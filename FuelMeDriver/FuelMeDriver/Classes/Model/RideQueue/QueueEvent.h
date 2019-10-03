//
//  QueueEvent.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/17/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RideDriverEnums.h"

@interface QueueEvent : NSObject

@property (nonatomic, readonly) DriverEventType eventType;
@property (nonatomic, readonly, copy) NSString *areaQueueName;

+ (instancetype)eventWithType:(DriverEventType)eventType andAreaQueueName:(NSString *)areaQueueName;
- (NSString *)welcomeMessage;
- (NSString *)alertTitle;
- (NSString *)alertMessage;

@end
