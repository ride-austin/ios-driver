//
//  CFViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/24/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "CFViewModel.h"
#import "CFFeedback.h"
#import "CFReasonDataModel.h"
#import "DriverManager.h"
#import "NSDictionary+JSON.h"
#import "NSString+Utils.h"
#import "RARideAPI.h"

@interface CFViewModel()
@property (nonatomic, nonnull) RARideDataModel *ride;
@end

@implementation CFViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _title = @"Cancel this ride?";
        _subtitle = @"xxx subtitle";
    }
    return self;
}

- (void)setRide:(RARideDataModel *)ride {
    _ride = ride;
    _title = @"Cancel this ride?";
}
- (void)getReasonsWithCompletion:(void (^)(NSError * _Nullable))completion {
    [RARideAPI getReasonsWithCompletion:^(NSArray<CFReasonDataModel *> *reasons, NSError *error) {
        if (error) {
            NSError *parsingError = nil;
            id json = [NSDictionary jsonFromResourceName:@"RIDES_CANCELLATION_REASONS"];
            _items = [MTLJSONAdapter modelsOfClass:CFReasonDataModel.class fromJSONArray:json error:&parsingError];
        } else {
            _items = reasons;
        }
        completion(error);
    }];
}

- (void)submitCancellationReason:(NSString *)reasonCode comment:(NSString *)comment withCompletion:(void(^)(NSError *error))completion {
    NSParameterAssert([reasonCode isKindOfClass:NSString.class]);
    CFFeedback *feedback = [CFFeedback feedbackForRide:self.ride.modelID];
    feedback.reasonCode = reasonCode;
    feedback.comment = comment;
    [[DriverManager shared] cancelTripWithFeedback:feedback andCompletion:completion];
}

@end
