//
//  NSNumber+UTC.m
//  Ride
//
//  Created by Kitos on 16/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "NSNumber+UTC.h"

@implementation NSNumber (UTC)

-(NSDate *)dateFromUTC{
    
    return [NSDate dateWithTimeIntervalSince1970:self.doubleValue/1000.0];
    
}

+(NSNumber *)UTCFromDate:(NSDate *)date {
    unsigned long long ti = (unsigned long long)(date.timeIntervalSince1970)*1000;
    return date ? [NSNumber numberWithUnsignedLongLong:ti] : nil;
}

@end
