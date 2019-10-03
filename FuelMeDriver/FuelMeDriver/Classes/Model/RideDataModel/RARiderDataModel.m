//
//  RARiderDataModel.m
//  RideDriver
//
//  Created by Roberto Abreu on 6/15/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARiderDataModel.h"

@implementation RARiderDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *propertiesMap = @{@"firstName"   : @"firstname",
                                    @"lastName"    : @"lastname",
                                    @"fullName"    : @"fullName",
                                    @"phoneNumber" : @"phoneNumber",
                                    @"photoURL"    : @"user.photoUrl",
                                    @"rating"      : @"rating"
                                    };
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:propertiesMap];
}

+ (NSValueTransformer *)photoURLJSONTransformer {
    return [MTLValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (NSString *)phoneNumber {
    return [[_phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

@end
