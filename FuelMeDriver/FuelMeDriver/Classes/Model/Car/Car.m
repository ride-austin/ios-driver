//
//  Car.m
//  RideAustin
//
//  Created by Tyson Bunch on 7/23/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import "Car.h"

@implementation Car

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *propertyMapping = @{ @"color" : @"color",
                                       @"inspectionStatus" : @"inspectionStatus",
                                       @"inspectionNotes" : @"inspectionNotes",
                                     //@"inspectionSticker": @"inspectionSticker",
                                       @"license" : @"license",
                                       @"make" : @"make",
                                       @"model" : @"model",
                                       @"year" : @"year",
                                       @"carCategories" : @"carCategories",
                                       @"isRemoved":@"removed",
                                       @"isSelected" : @"selected",
                                       @"insuranceExpiryDate" : @"insuranceExpiryDate",
                                       @"insurancePictureUrl" : @"insurancePictureUrl",
                                       @"photoUrl" : @"photoUrl"
                                      };
    
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:propertyMapping];
}

+ (NSValueTransformer *)photoUrlJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *photoUrl, BOOL *success, NSError *__autoreleasing *error) {
        return [NSURL URLWithString:photoUrl];
    } reverseBlock:^id(NSURL *url, BOOL *success, NSError *__autoreleasing *error) {
        return url.absoluteString;
    }];
}

+ (NSValueTransformer *)insuranceExpiryDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

- (NSString *)carName {
    return [NSString stringWithFormat:@"%@ %@", self.make, self.model];
}

@end
