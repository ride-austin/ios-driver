//
//  RADriverStatDataModel.m
//  RideDriver
//
//  Created by Roberto Abreu on 7/27/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RADriverStatDataModel.h"

@implementation RADriverStatDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"name" : @"name",
              @"value" : @"value",
              @"outOfTotal" : @"outOfTotal",
              @"statDescription" : @"description"
            };
}

- (double)rate {
    return self.value.doubleValue * 100 / self.outOfTotal.doubleValue;
}

@end
