//
//  NSNumber+UTC.h
//  Ride
//
//  Created by Kitos on 16/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (UTC)

-(NSDate* _Nonnull)dateFromUTC;

+(NSNumber* _Nullable)UTCFromDate:(NSDate* _Nonnull)date;

@end
