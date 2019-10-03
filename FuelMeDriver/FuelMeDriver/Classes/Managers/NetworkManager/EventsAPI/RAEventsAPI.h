//
//  RAEventsAPI.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RABaseAPI.h"
#import "RAEventDataModel.h"

@interface RAEventsAPI : RABaseAPI
+(void)getEventsWithLastReceivedEvent:(NSNumber *_Nullable)highestEventID CompletionBlock:(void (^ _Nonnull)(NSArray<RAEventDataModel *>* _Nullable events, NSNumber * _Nullable lastReceivedEventID, NSError * _Nullable error))completionHandler;
@end
