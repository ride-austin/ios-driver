//
//  QueueZone.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/17/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface QueueZone : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSString *areaQueueName;
@property (nonatomic, readonly) NSURL *iconUrl;
@property (nonatomic) NSDictionary<NSString *, NSNumber *> *lengths;

@end
