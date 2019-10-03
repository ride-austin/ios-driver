//
//  NSHTTPURLResponse+Utils.m
//  RideDriver
//
//  Created by Kitos on 28/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "NSHTTPURLResponse+Utils.h"

#import "NSString+Utils.h"

@implementation NSHTTPURLResponse (Utils)

-(NSDate *)date{
    NSDictionary *allHeaders = self.allHeaderFields;
    NSString *dateString = allHeaders[@"Date"];
    return [dateString httpHeaderResponseDate];
}

@end
