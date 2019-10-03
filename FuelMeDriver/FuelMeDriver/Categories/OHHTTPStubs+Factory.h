//
//  OHHTTPStubs+Factory.h
//  RideDriver
//
//  Created by Roberto Abreu on 5/28/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>

@interface OHHTTPStubs (Factory)

#pragma mark Response Handlers
+ (OHHTTPStubsResponseBlock)handlerResponseWithStatusCode:(int)statusCode andResponseString:(NSString*)responseString;
+ (OHHTTPStubsResponseBlock)handlerResponseWithStatusCode:(int)statusCode andFileName:(NSString*)fileName;
+ (OHHTTPStubsResponseBlock)handlerResponseWithJSONObject:(id)jsonObject;
+ (OHHTTPStubsResponseBlock)handlerWithError:(NSError *)error;
+ (OHHTTPStubsResponseBlock)handlerWithString:(NSString *)responseString andBlock:(void(^)(void))beforeCompletionBlock;
#pragma mark GET

+ (void)addStubWithGETRequestPath:(NSString*)path statusCode:(int)statusCode andResponseString:(NSString*)response;
+ (void)addStubWithGETRequestPath:(NSString*)path statusCode:(int)statusCode andResponseFileName:(NSString*)fileName;
+ (void)addStubWithGETRequestPath:(NSString*)path responseHandler:(OHHTTPStubsResponseBlock)handler;

#pragma mark POST

+ (void)addStubWithPOSTRequestPath:(NSString*)path statusCode:(int)statusCode andResponseString:(NSString*)response;
+ (void)addStubWithPOSTReqeuestPath:(NSString*)path statusCode:(int)statusCode andResponseFileName:(NSString*)fileName;
+ (void)addStubWithPOSTRequestPath:(NSString*)path responseHandler:(OHHTTPStubsResponseBlock)handler;

#pragma mark PUT

+ (void)addStubWithPUTRequestPath:(NSString*)path statusCode:(int)statusCode andResponseString:(NSString*)response;
+ (void)addStubWithPUTRequestPath:(NSString*)path responseHandler:(OHHTTPStubsResponseBlock)handler;

#pragma mark DELETE

+ (void)addStubWithDELETERequestPath:(NSString*)path statusCode:(int)statusCode andResponseString:(NSString*)response;
+ (void)addStubWithDELETERequestPath:(NSString*)path responseHandler:(OHHTTPStubsResponseBlock)handler;

#pragma mark - Stub Registration

+ (void)addStubWithRequestPath:(NSString*)path matchingHttpMethod:(NSString*)httpMethod responseHandler:(OHHTTPStubsResponseBlock)handler;
+ (void)addStubWithRequestPath:(NSString *)path
                        method:(NSString *)httpMethod
                    statusCode:(int)statusCode
                   andFileName:(NSString *)fileName
           requiringParameters:(NSArray<NSString *> *)mandatoryParameters;
@end

@interface OHHTTPStubsResponse (Factory)
#pragma mark Response
+ (OHHTTPStubsResponse *)emptyJSONArray;

@end
