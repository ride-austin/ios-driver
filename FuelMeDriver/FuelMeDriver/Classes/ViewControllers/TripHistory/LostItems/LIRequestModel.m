//
//  LIRequestModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/26/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "LIRequestModel.h"

#import "LIFieldViewModel.h"
#import "NSDate+Utils.h"
#import "UIImage+Ride.h"

@implementation LIRequestModel

+ (instancetype)itemFromFormValues:(NSDictionary *)formValues rideId:(NSNumber *)rideId andFields:(NSArray<LIFieldViewModel *> *)fields {
    return [[self alloc] initFromFormValues:formValues rideId:rideId andFields:fields];
}

- (instancetype)initFromFormValues:(NSDictionary *)formValues rideId:(NSNumber *)rideId andFields:(NSArray<LIFieldViewModel *> *)fields {
    if (self = [super init]) {
        NSMutableDictionary *mParams = [NSMutableDictionary new];
        NSMutableDictionary *mImages = [NSMutableDictionary new];
        mParams[@"rideId"] = rideId;
        for (LIFieldViewModel *fieldVm in fields) {
            if (formValues[fieldVm.variable]) {
                id formValue = formValues[fieldVm.variable];
                BOOL isDate  = [formValue isKindOfClass:[NSDate  class]];
                BOOL isImage = [formValue isKindOfClass:[UIImage class]];
                if (isDate) {
                    mParams[fieldVm.variable] = [formValues[fieldVm.variable] ISO8601StringFromDate];
                } else if (isImage) {
                    mImages[fieldVm.variable] = [formValues[fieldVm.variable] compressToMaxSize:300000];
                } else {
                    mParams[fieldVm.variable] =  formValues[fieldVm.variable];
                }
            }
        }
        _parameters = mParams.copy;
        _images     = mImages.copy;
    }
    return self;
}

@end
