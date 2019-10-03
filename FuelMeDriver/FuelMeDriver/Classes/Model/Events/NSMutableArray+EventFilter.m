//
//  NSMutableArray+EventFilter.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 3/9/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "NSMutableArray+EventFilter.h"

#import "RAEventDataModel.h"

@implementation NSMutableArray (EventFilter)

- (void)removeOldEventsForEventType:(DriverEventType)eventType {
    if (self.count <= 1) {
        return;
    }
    NSArray<RAEventDataModel *> *duplicatedEvents = [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RAEventDataModel   * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.type == eventType;
    }]];
    if (duplicatedEvents.count > 1) {
        NSArray *unnecessaryEvents = [duplicatedEvents subarrayWithRange:NSMakeRange(0, duplicatedEvents.count - 1)];
        [self removeObjectsInArray:unnecessaryEvents];
    }
}

@end
