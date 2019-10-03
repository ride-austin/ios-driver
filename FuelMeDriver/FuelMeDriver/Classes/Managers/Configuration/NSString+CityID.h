//
//  NSString+CityID.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/24/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AppendType) {
    AppendAsFirstParameter,
    AppendAsLastParameter
};

@interface NSString (CityID)
- (NSString *)pathWithCityAppendType:(AppendType)type;
@end
