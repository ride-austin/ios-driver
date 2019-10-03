//
//  RARideDataModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RARideDataModel.h"

#import "ConfigurationManager.h"
#import "NSDictionary+JSON.h"
#import "RAPickupManager.h"

@interface RARideDataModel ()

@property (nonatomic) NSNumber *estimatedTimeArrive;

//This properties should be inside start/end keys
//But server side doesn't have in that way yet
@property (nonatomic) NSNumber *startLatitude;
@property (nonatomic) NSNumber *startLongitude;
@property (nonatomic) NSNumber *endLatitude;
@property (nonatomic) NSNumber *endLongitude;

@end

@implementation RARideDataModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    if (self = [super initWithDictionary:dictionaryValue error:error]) {
        if (!self.comment || ![self.comment isKindOfClass:[NSString class]]) {
            _comment = @"";
        }
        
        if ([self.startAddress isKindOfClass:RARideAddressDataModel.class]) {
            CLLocation *startAddressRefined = [RAPickupManager refinePickupLocation:[[CLLocation alloc] initWithLatitude:self.startLatitude.doubleValue longitude:self.startLongitude.doubleValue]];
            [self.startAddress setLocationByCoordinate:startAddressRefined.coordinate];
        }
        
        if ([self.endAddress isKindOfClass:RARideAddressDataModel.class]) {
            [self.endAddress setLocationByCoordinate:CLLocationCoordinate2DMake(self.endLatitude.doubleValue, self.endLongitude.doubleValue)];
        }
        
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *propertiesMap = @{ @"rider" : @"rider",
                                     @"comment" : @"comment",
                                     @"status" : @"status",
                                     @"estimatedTimeArrive" : @"estimatedTimeArrive",
                                     @"surgeFactor" : @"surgeFactor",
                                     @"startAddress" : @"start",
                                     @"endAddress" : @"end",
                                     @"requestedCarType" : @"requestedCarType",
                                     @"requestedDriverTypes" : @"requestedDriverTypes",
                                     @"rideRequestUpgrade" : @"upgradeRequest",
                                     @"startLatitude" :  @"startLocationLat",
                                     @"startLongitude" : @"startLocationLong",
                                     @"endLatitude" : @"endLocationLat",
                                     @"endLongitude" : @"endLocationLong",
                                     @"driverPayment" : @"driverPayment",
                                     @"nextRide" : @"nextRide"
                                    };
    
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:propertiesMap];
}

#pragma mark - Mapping Transformer

+ (NSValueTransformer*)riderJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RARiderDataModel class]];
}

+ (NSValueTransformer*)requestedCarTypeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RACarCategoryDataModel class]];
}

+ (NSValueTransformer*)requestedDriverTypesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:RADriverType.class];
}

+ (NSValueTransformer*)rideRequestUpgradeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RideRequestUpgrade class]];
}

+ (NSValueTransformer*)startAddressJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RARideAddressDataModel class]];
}

+ (NSValueTransformer*)endAddressJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RARideAddressDataModel class]];
}

+ (NSValueTransformer*)driverPaymentJSONTransformer {
    return [self stringToNumberTransformer];
}

#pragma mark - Properties

- (NSString *)eta {
    if (!self.estimatedTimeArrive) {
        return @"N/A";
    }
    
    int estimatedTimeArrive= self.estimatedTimeArrive.intValue;
    int minutes = estimatedTimeArrive / 60;
    
    if (minutes < 1) {
        return @"<1 min";
    }
    if (minutes == 1) {
        return @"1 min";
    } else {
        return [NSString stringWithFormat:@"%d mins", minutes];
    }
}

- (BOOL)containsDriverType:(DriverType)driverType {
    for (RADriverType *type in self.requestedDriverTypes) {
        if (type.driverType == driverType) {
            return true;
        }
    }
    return false;
}

- (BOOL)hasSurgeFactor {
    return self.surgeFactor && [self.surgeFactor doubleValue] > 1.0;
}

- (BOOL)isValid {
    return self.modelID && self.startAddress.isValid;
}

#pragma mark - Methods

- (void)upgradeRequestWithTarget:(NSString*)target {
    RideRequestUpgrade *upgradeRequest = [[RideRequestUpgrade alloc] init];
    upgradeRequest.source = self.requestedCarType.carCategory;
    upgradeRequest.target = target;
    upgradeRequest.status = UpgradeRequested;
    self.rideRequestUpgrade = upgradeRequest;
}

@end

#pragma mark - RARideDataModel EventStubGenerator

@implementation RARideDataModel (EventStubGenerator)

+ (instancetype)rideFromFileName:(NSString *)fileName {
    return [super modelFromFileName:fileName];
}

- (NSDictionary *)jsonObject {
    NSError *error;
    NSDictionary *json = [MTLJSONAdapter JSONDictionaryFromModel:self error:&error];
    NSAssert(error == nil, @"%@ failed with error %@",NSStringFromClass([self class]),error);
    return json;
    
}

@end
