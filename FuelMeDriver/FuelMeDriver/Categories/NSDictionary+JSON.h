//
//  NSDictionary+JSON.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)
+ (id)jsonFromResourceName:(NSString *)resourceName;
+ (id)jsonFromResourceName:(NSString *)resourceName error:(NSError **)error;
+ (id)jsonFromResourceName:(NSString *)resourceName bundle:(NSBundle *)bundle error:(NSError **)error;
@end
