//
//  RACarDatamodel.m
//  RideAustin
//
//  Created by Carlos Alcala on 01/24/17.
//  Copyright © 2017 Crossover Markets Inc. All rights reserved.
//

#import "RACarDataModel.h"

@implementation RACarDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RACarDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"make": @"make",
             @"model": @"model",
             @"year": @"year",
             };
}

- (NSString*)fullDescription {
    return [NSString stringWithFormat:@"%@, %@", self.model, self.make];
}

@end
