//
//  RADateManager.h
//  RideDriver
//
//  Created by Roberto Abreu on 27/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TimeDateBlock)(NSDate *date,NSError *error);

@interface RADateManager : NSObject

+ (instancetype)sharedInstance;

- (NSDate*)currentDate;
- (void)fetchCurrentDate:(TimeDateBlock)completion;

@end
