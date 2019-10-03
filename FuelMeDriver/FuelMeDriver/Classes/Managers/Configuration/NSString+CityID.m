//
//  NSString+CityID.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 11/24/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NSString+CityID.h"

#import "ConfigurationManager.h"

@implementation NSString (CityID)

- (NSString *)pathWithCityAppendType:(AppendType)type {
    RACity *city = [ConfigurationManager shared].global.currentCity;
    if ([city.cityID isKindOfClass:[NSNumber class]]) {
        switch (type) {
            case AppendAsFirstParameter:
                return [NSString stringWithFormat:@"%@?%@",self,city.requestParameterString];
            case AppendAsLastParameter:
                return [NSString stringWithFormat:@"%@&%@",self,city.requestParameterString];
        }
    } else {
        return self;
    }
}

@end
