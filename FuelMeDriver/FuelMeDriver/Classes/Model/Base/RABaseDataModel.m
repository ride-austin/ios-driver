//
//  RABaseDataModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseDataModel.h"

#import "GoogleMapsManager.h"
#import "NSDictionary+JSON.h"
#import "NSNumber+UTC.h"

@implementation RABaseDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"modelID": @"id"
            };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    
    return dateFormatter;
}

+ (NSDateFormatter *)dateFormatterDB {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return df;
}

@end

@implementation RABaseDataModel (Transformer)

+ (MTLValueTransformer *)stringToNumberTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *numberString, BOOL *success, NSError *__autoreleasing *error) {
        return [NSNumber numberWithDouble:numberString.doubleValue];
    } reverseBlock:^id(NSNumber *number, BOOL *success, NSError *__autoreleasing *error) {
        return [number stringValue];
    }];
}

+ (MTLValueTransformer *)stringToDateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (MTLValueTransformer *)stringToDateTransformerDB {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatterDB dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatterDB stringFromDate:date];
    }];
}

+ (MTLValueTransformer *)numberToDateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *dateNumber, BOOL *success, NSError *__autoreleasing *error) {
        return [dateNumber dateFromUTC];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [NSNumber UTCFromDate:date];
    }];
}

+ (MTLValueTransformer *)stringToGMSPathTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *pathString, BOOL *success, NSError *__autoreleasing *error) {
        GMSMutablePath *mutablePath = [GMSMutablePath new];
        NSArray * components = [pathString componentsSeparatedByString:@" "];
        for (NSString  *locationComponent in components) {
            CLLocation *location = [CLLocation locationFromString:locationComponent];
            if (location) {
                [mutablePath addCoordinate:location.coordinate];
            }
        }
        return mutablePath;
    }];
}

- (GMSMutablePath *)pathFromString:(NSString *)pathString {
    if ([pathString isKindOfClass:[NSString class]]) {
        GMSMutablePath *mutablePath = [GMSMutablePath new];
        NSArray * components = [pathString componentsSeparatedByString:@" "];
        for (NSString  *locationComponent in components) {
            CLLocation *location = [CLLocation locationFromString:locationComponent];
            if (location) {
                [mutablePath addCoordinate:location.coordinate];
            }
        }
        return mutablePath;
    } else {
        return nil;
    }
}

@end

@implementation RABaseDataModel (JSONConstructors)

+ (instancetype)modelFromFileName:(NSString *)fileName {
    NSError *error = nil;
    id json = [NSDictionary jsonFromResourceName:fileName error:&error];
    NSAssert(error == nil, @"%@ modelFromFileName-jsonFromResourceName failed with error %@",NSStringFromClass([self class]),error);
    NSAssert([json isKindOfClass:[NSDictionary class]], @"modelFromFileName expects json dictionary not array");
    id model = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:json error:&error];
    NSAssert(error == nil, @"%@ modelFromFileName-MTLJSONAdapter failed with error %@",NSStringFromClass([self class]),error);
    return model;
}

+ (void)testReversibleModelInFileName:(NSString *)fileName {
    id json = [self modelFromFileName:fileName];
    NSError *error = nil;
    NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:json error:&error];
    NSAssert(error == nil, @"This object %@ needs to configure reverse transformation, because of error %@",NSStringFromClass([self class]),error);
    DBLog(@"dict %@", dict)
}

@end
