//
//  NSString+PhoneUtils.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/2/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PhoneUtils)

-(NSString*)clearedPhoneNumber;
-(NSString*)countryCode;
-(BOOL)hasCountryCode:(NSString*)countryCode;

@end
