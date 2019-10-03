//
//  ConfigRegistration.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "ConfigRegistration.h"

@implementation ConfigRegistration

- (instancetype)initWithCity:(RACity *)city andDetail:(RACityDetail *)cityDetail {
    self = [super init];
    if (self) {
        if (city && cityDetail) {
            self.city = city;
            self.cityDetail = cityDetail;
        } else {
            return nil;
        }
    }
    return self;
}

+ (instancetype)configWithCity:(RACity *)city andDetail:(RACityDetail *)cityDetail {
    ConfigRegistration *config = [[ConfigRegistration alloc] initWithCity:city andDetail:cityDetail];
    return config;
}

- (NSString *)appName {
    return self.city.appName;
}

@end
