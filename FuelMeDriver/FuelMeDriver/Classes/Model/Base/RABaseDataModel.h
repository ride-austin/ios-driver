//
//  RABaseDataModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/19/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <Mantle/Mantle.h>

@interface RABaseDataModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSNumber *modelID;

@end

@interface RABaseDataModel (Transformer)

+ (MTLValueTransformer *)stringToNumberTransformer;
+ (MTLValueTransformer *)stringToDateTransformer;
+ (MTLValueTransformer *)stringToDateTransformerDB;
+ (MTLValueTransformer *)numberToDateTransformer;
+ (MTLValueTransformer *)stringToGMSPathTransformer;
- (GMSMutablePath *)pathFromString:(NSString *)pathString;

@end

@interface RABaseDataModel (JSONConstructors)

+ (instancetype)modelFromFileName:(NSString *)fileName;
+ (void)testReversibleModelInFileName:(NSString *)fileName;

@end
