//
//  RACarCategoryDataModel.m
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RACarCategoryDataModel.h"

@implementation RACarCategoryDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RACarCategoryDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"baseFare": @"baseFare",
             @"minimumFare": @"minimumFare",
             @"bookingFee" : @"bookingFee",
             @"cancellationFee" : @"cancellationFee",
             @"ratePerMile": @"ratePerMile",
             @"ratePerMinute": @"ratePerMinute",
             @"maxPersons": @"maxPersons",
             @"title": @"title",
             @"carCategory": @"carCategory",
             @"catDescription": @"description",
             @"iconURL": @"plainIconUrl",
             @"order" : @"order",
             @"raFeeFactor" : @"raFeeFactor",
             @"tncFeeRate" : @"tncFeeRate",
             @"processingFee" : @"processingFee",
             @"processingFeeRate" : @"processingFeeRate",
             @"processingFeeText" : @"processingFeeText",
             @"configuration"     : @"configuration"
             };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)iconURLJSONTransformer {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)baseFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)minimumFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)bookingFeeJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)cancellationFeeJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)ratePerMileJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)ratePerMinuteJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)configurationJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        return [MTLJSONAdapter modelOfClass:RACarCategoryConfigurationModel.class fromJSONDictionary:json error:nil];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[RACarCategoryConfigurationModel class]]) {
            NSDictionary *json = [MTLJSONAdapter JSONDictionaryFromModel:value error:error];
            if ([json isKindOfClass:[NSDictionary class]]) {
                NSData *dataRepresentation = [NSJSONSerialization dataWithJSONObject:json options:0 error:error];
                NSString *string = [[NSString alloc] initWithData:dataRepresentation encoding:NSUTF8StringEncoding];
                return string;
            }
            NSAssert(*error == nil, @"RACarCategoryConfigurationModel reverseBlock failed with error: %@", *error);
        }
        
        return nil;
    }];
}

- (BOOL)shouldShowAreaQueue {
    //if configuration.supportsAreaQueue, shouldShowAreaQueue is yes by default
    return self.configuration.supportsAreaQueue == nil || self.configuration.supportsAreaQueue.boolValue;
}

- (NSString*)iconName{
    if (!self.iconURL) {
        return self.title.lowercaseString;
    }else{
        return [self.iconURL.absoluteString lastPathComponent];
    }
}

- (UIImage*)icon{
    if (self.iconURL) {
        NSString *docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSString *fullPath = [docDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"category/%@",self.iconName]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:fullPath]) {
            return [UIImage imageWithContentsOfFile:fullPath];
        }else{
            return [UIImage imageNamed:@"regular"];
        }
    }
    
    return [UIImage imageNamed:self.iconName];
}

@end
