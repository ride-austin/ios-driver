//
//  RAEventsAPI.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RAEventsAPI.h"

#import "DriverManager.h"
#import "ErrorReporter.h"
#import "NSMutableArray+EventFilter.h"

@implementation RAEventsAPI
+(void)getEventsWithLastReceivedEvent:(NSNumber *)highestEventID CompletionBlock:(void (^ _Nonnull)(NSArray<RAEventDataModel *> * _Nullable, NSNumber * _Nullable, NSError * _Nullable))completionHandler {
    NSString *path = kPathEvents;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"avatarType"]        = @"DRIVER";
    params[@"lastReceivedEvent"] = highestEventID;
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    [objectManager.HTTPClient setParameterEncoding: AFRKFormURLParameterEncoding];
    
    [objectManager.HTTPClient getPath:path
                           parameters:params
                              success:^(AFRKHTTPRequestOperation *operation, id responseObject) {
                                  //RA-3434. Marcos was not receiving that message but a crash, so better avoid this if not authed.
                                  if ([RASessionManager shared].isSignedIn) {
                                      dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                                          long long xmax = highestEventID.longLongValue;
                                          NSError *error = nil;
                                          NSMutableArray<RAEventDataModel *>* events = (NSMutableArray *)[MTLJSONAdapter modelsOfClass:RAEventDataModel.class fromJSONArray:responseObject error:&error];
                                          if (!error) {
                                              [events removeOldEventsForEventType:RiderLocationUpdated];
                                              [events removeOldEventsForEventType:QueueUpdate];
                                              [events removeOldEventsForEventType:RideDestinationUpdated];
                                              [events removeOldEventsForEventType:CarCategoryChanged];
                                              for (RAEventDataModel *model in events) {
                                                  if (model.type != RiderLocationUpdated) {
                                                      BFLog(@"Poll Event: %@ with Id %@",model.eventType,model.modelID);
                                                  }
                                                  xmax = MAX(xmax,model.modelID.longLongValue);
                                              }
                                          }
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completionHandler(events,@(xmax),error);
                                          });
                                      });
                                  } else {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          completionHandler(nil,nil,nil);
                                      });
                                  }
                              }
                              failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
                                  [ErrorReporter recordError:error withDomainName:GETEvents];
                                  DBLog(@"Error: [%d] %@", (int)error.code, error.localizedDescription);
                                  NSError *raError = [error filteredErrorAtReponse:operation.response];
                                  completionHandler(nil,nil,raError);
                              }];
    
}
@end
