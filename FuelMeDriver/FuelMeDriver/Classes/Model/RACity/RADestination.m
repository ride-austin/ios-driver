//
//  RADestination.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/25/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RADestination.h"

@interface RADestination()

@property (nonatomic) NSArray <NSString *> *prefixes;
@property (nonatomic) NSArray <NSString *> *containStrings;
@property (nonatomic) NSString *googleReference;
@property (nonatomic) NSString *secondaryAddress;

@end

@implementation RADestination

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"containStrings"  :@"contains",
              @"placeDescription":@"description",
              @"prefixes"        :@"prefixes",
              @"primaryAddress"  :@"primaryAddress",
              @"googleReference" :@"reference",
              @"secondaryAddress": @"secondaryAddress"
            };
}

+ (instancetype)austinAirport {
    RADestination *dest = [RADestination new];
    dest.prefixes = @[@"ai",@"au",@"airpot"];
    dest.containStrings = @[@"airport"];
    dest.placeDescription = @"Austin-Bergstrom International Airport, Presidential Boulevard, Austin, TX, United States";
    dest.googleReference = @"ChIJRf9KizuxRIYRaCfcyaj8pxw";
    dest.primaryAddress = @"Austin-Bergstrom International Airport";
    dest.secondaryAddress = @"Presidential Boulevard, Austin, TX, United States";
    return dest;
}

- (NSDictionary *)userInfo {
    return
    @{@"description": self.placeDescription,
      @"reference": self.googleReference,
      @"primaryAddress": [[NSAttributedString alloc] initWithString:self.primaryAddress],
      @"secondaryAddress": [[NSAttributedString alloc] initWithString:self.secondaryAddress]
      };
}

- (BOOL)didMatchString:(NSString *)searchString {
    NSString *cleanStr = searchString.lowercaseString;
    for (NSString *prefix in self.prefixes) {
        if ([cleanStr hasPrefix:prefix]) {
            return YES;
        }
    }
    for (NSString *keyword in self.containStrings) {
        if ([cleanStr containsString:keyword]) {
            return YES;
        }
    }
    return NO;
}

@end
