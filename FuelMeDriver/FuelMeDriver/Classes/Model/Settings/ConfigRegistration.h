//
//  ConfigRegistration.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RACity.h"
#import "RACityDetail.h"

@interface ConfigRegistration : NSObject

@property (nonatomic) RACity *city;
@property (nonatomic) RACityDetail *cityDetail;

+ (instancetype)configWithCity:(RACity *)city andDetail:(RACityDetail *)cityDetail;
- (NSString *)appName;

@end
