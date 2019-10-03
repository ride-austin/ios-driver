//
//  RideRate.h
//  RideDriver
//
//  Created by Roberto Abreu on 16/10/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RideRate : NSObject

@property (nonatomic,strong) NSString *rideId;
@property (nonatomic) CGFloat rate;

- (id)initWithRideId:(NSString*)rideId andRate:(CGFloat)rate;

@end
