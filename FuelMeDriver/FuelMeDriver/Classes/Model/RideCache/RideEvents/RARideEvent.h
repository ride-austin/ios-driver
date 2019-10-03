//
//  RARideEvent.h
//  RideDriver
//
//  Created by Kitos on 6/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RARideEventProtocol <NSObject>

@property (nonatomic, readonly) NSDictionary *jsonObject;
@property (nonatomic, readonly) NSString *hashString;

+ (NSString*)eventType;

@end

@interface RARideEvent : NSObject

@property (nonatomic, strong) NSString *event;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, strong) NSString *rideID;

- (instancetype)initWithRideID:(NSString*)rideID;

@end

@interface RARideEvent (EventProtocol) <RARideEventProtocol>
@end

@interface RARideEvent (Coding) <NSCoding>
@end
