//
//  NSNumber+Utils.h
//  RideDriver
//
//  Created by Carlos Alcala on 7/20/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Utils)

- (NSString *)currencyString;
- (NSString *)trimZeros;
- (NSString *)shortString;
- (NSString *)timeFormat;

@end
