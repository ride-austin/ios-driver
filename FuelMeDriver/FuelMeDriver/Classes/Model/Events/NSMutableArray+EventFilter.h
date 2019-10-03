//
//  NSMutableArray+EventFilter.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 3/9/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RideDriverEnums.h"

@interface NSMutableArray (EventFilter)

- (void)removeOldEventsForEventType:(DriverEventType)eventType;

@end
