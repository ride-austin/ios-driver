//
//  GeocodeService.h
//  RideDriver
//
//  Created by Roberto Abreu on 7/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LocationServiceAddressBlock)(NSString* zip, NSString *address, NSString *fullAddress, NSString* city, NSString *state, NSString *county, NSString *neighborhood, NSError *error);

@interface GeocodeService : NSObject

+ (instancetype)sharedInstance;
- (void)reverseGeo:(CLLocation*)location completeBlock:(LocationServiceAddressBlock)completeBlock;

@end
