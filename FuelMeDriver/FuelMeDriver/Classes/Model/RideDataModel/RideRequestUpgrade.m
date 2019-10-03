//
//  RideRequestUpgrade.m
//  RideDriver
//
//  Created by Roberto Abreu on 6/14/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RideRequestUpgrade.h"

@implementation RideRequestUpgrade

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"source" : @"source",
              @"target" : @"target",
              @"status" : @"status"
            };
}

+ (NSValueTransformer *)statusJSONTransformer {
    NSDictionary *states = @{@"REQUESTED" : @(UpgradeRequested),
                             @"ACCEPTED"  : @(UpgradeAccepted),
                             @"DECLINED"  : @(UpgradeDeclined)
                            };
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return states[value] ?: @(UpgradeInvalid);
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        //Reverse Only use for UITesting
        NSString *stateKey = [states allKeysForObject:value].firstObject;
        return stateKey;
    }];
}

- (NSString *)targetName {
    if ([self.target isEqualToString:@"REGULAR"]) {
        return @"STANDARD";
    }
    return self.target;
}

@end
