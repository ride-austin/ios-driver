//
//  CFFeedback.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 3/29/18.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFFeedback : NSObject
@property (nonatomic, nonnull, readonly) NSString *rideID;
@property (nonatomic, nullable) NSString *reasonCode;
@property (nonatomic, nullable) NSString *comment;
+ (instancetype _Nonnull )feedbackForRide:(NSNumber *_Nonnull)rideID;
@end
