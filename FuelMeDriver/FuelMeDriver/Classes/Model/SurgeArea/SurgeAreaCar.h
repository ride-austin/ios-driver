//
//  SurgeAreaCar.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 4/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SurgeAreaCar : NSObject
@property (nonatomic, readonly) NSString *category;
@property (nonatomic, readonly) NSNumber *factor;
+(instancetype)carWithCategory:(NSString *)category andFactor:(NSNumber *)factor;

/**
 *  @brief returns YES if self is a valid surge and greater than car
 */
-(BOOL)hasSurgeGreaterThanCar:(SurgeAreaCar *)car;
@end
