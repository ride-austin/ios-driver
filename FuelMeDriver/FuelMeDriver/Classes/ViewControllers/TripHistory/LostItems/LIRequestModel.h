//
//  LIRequestModel.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/26/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LIFieldViewModel;

@interface LIRequestModel : NSObject

@property (nonatomic, readonly) NSDictionary<NSString *, id> *parameters;
@property (nonatomic, readonly) NSDictionary<NSString *, NSData *> *images;

+ (instancetype)itemFromFormValues:(NSDictionary *)formValues rideId:(NSNumber *)rideId andFields:(NSArray<LIFieldViewModel *>*)fields;

@end
