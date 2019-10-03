//
//  EventStubModel.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/4/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "EventStubModel.h"
@interface EventStubModel()

/**
 date that the event will be sent
 */
@property (nonatomic, readonly) NSDate * _Nonnull date;
@end
@implementation EventStubModel
-(instancetype)initWithSeconds:(NSTimeInterval)secondsFromLaunch launchDate:(NSDate *)launchDate model:(RAEventDataModel *)model {
    if (self = [super init]) {
        _date =  [launchDate dateByAddingTimeInterval:secondsFromLaunch];
        _model = model;
        if (_model.type == RideRequested) {
            [_model updateRideAcceptanceWithLaunchDate:_date];
        }
    }
    return self;
}

-(BOOL)isInPresentOrPast {
    return [self.date compare:[NSDate date]] != NSOrderedDescending;
}
-(NSArray *)jsonArray {
    if (self.model) {
        NSError *error;
        NSDictionary *jsonObject = [MTLJSONAdapter JSONDictionaryFromModel:self.model error:&error];
        NSAssert(error == nil, @"EventStubModel failed with error %@",error);
        return @[jsonObject];
    } else {
        return @[];
    }
}
@end


#import "NSString+urlParameters.h"
@implementation EventStubModel (RequestModelIDComparison)
-(BOOL)isNotYetReceivedByRequest:(NSURLRequest *)request {
    NSString *urlParameters = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    NSDictionary *params = urlParameters.dictionary;
    
    NSString *lastReceivedEvent = params[@"lastReceivedEvent"];
    if (lastReceivedEvent) {
        return self.model.modelID.integerValue > lastReceivedEvent.integerValue;
    } else {
        return YES;
    }
}
@end


@implementation EventStubModel (Duplication)
+(instancetype)eventStubFromStub:(EventStubModel *)stub afterSeconds:(NSTimeInterval)seconds {
    RAEventDataModel *newModel = stub.model.copy;
    [newModel incrementModelId];
    return [[EventStubModel alloc] initWithSeconds:seconds launchDate:stub.date model:newModel];
}
@end
