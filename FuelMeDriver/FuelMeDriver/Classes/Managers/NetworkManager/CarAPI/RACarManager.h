//
//  RACarManager.h
//  Ride
//
//  Created by Carlos Alcala on 11/25/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RACarAPI.h"

@interface RACarManager : NSObject

@property (nonatomic, strong) NSArray <RACarDataModel *> *cars;

+ (RACarManager *)shared;

+ (NSArray *)cars;
- (NSArray *)getYearsWithOrder:(BOOL)ASC andMinYear:(NSNumber *)minYear;
- (NSArray *)getMakesWithOrder:(BOOL)ASC andYear:(NSString *)year;
- (NSArray *)getModelsWithOrder:(BOOL)ASC withMake:(NSString *)make andYear:(NSString *)year;

@end
