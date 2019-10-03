//
//  OHHTTPStubs+Factory.m
//  RideDriver
//
//  Created by Roberto Abreu on 5/28/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "OHHTTPStubs+Factory.h"
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import "NSString+urlParameters.h"
@implementation OHHTTPStubs (Factory)

#pragma mark Response Handlers
+ (OHHTTPStubsResponseBlock)handlerResponseWithStatusCode:(int)statusCode andResponseString:(NSString*)responseString {
    return ^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        return [OHHTTPStubsResponse responseWithData:data statusCode:statusCode headers:@{@"Content-type":@"application/json"}];
    };
}
+ (OHHTTPStubsResponseBlock)handlerResponseWithStatusCode:(int)statusCode andFileName:(NSString*)fileName {
    return ^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        NSAssert(path, @"Not file found with fileName : %@",fileName);
        return [OHHTTPStubsResponse responseWithFileAtPath:path statusCode:statusCode headers:@{@"Content-type":@"application/json"}];
    };
}
+ (OHHTTPStubsResponseBlock)handlerResponseWithJSONObject:(id)jsonObject {
    return ^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithJSONObject:jsonObject statusCode:200 headers:nil];
    };
}
+ (OHHTTPStubsResponseBlock)handlerWithError:(NSError *)error {
    return ^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:error];
    };
}


+ (OHHTTPStubsResponseBlock)handlerWithString:(NSString *)responseString andBlock:(void(^)(void))beforeCompletionBlock {
    return ^OHHTTPStubsResponse *(NSURLRequest *request) {
        beforeCompletionBlock();
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:@{@"Content-type":@"application/json"}];
    };
}
#pragma mark GET

+ (void)addStubWithGETRequestPath:(NSString*)path statusCode:(int)statusCode andResponseString:(NSString*)response {
    [self addStubWithGETRequestPath:path responseHandler:[self handlerResponseWithStatusCode:statusCode andResponseString:response]];
}

+ (void)addStubWithGETRequestPath:(NSString*)path statusCode:(int)statusCode andResponseFileName:(NSString*)fileName {
    [self addStubWithGETRequestPath:path responseHandler:[self handlerResponseWithStatusCode:statusCode andFileName:fileName]];
}

+ (void)addStubWithGETRequestPath:(NSString*)path responseHandler:(OHHTTPStubsResponseBlock)handler {
    [self addStubWithRequestPath:path matchingHttpMethod:@"GET" responseHandler:handler];
}

#pragma mark POST

+ (void)addStubWithPOSTRequestPath:(NSString*)path statusCode:(int)statusCode andResponseString:(NSString*)response {
    [self addStubWithPOSTRequestPath:path responseHandler:[self handlerResponseWithStatusCode:statusCode andResponseString:response]];
}

+ (void)addStubWithPOSTReqeuestPath:(NSString*)path statusCode:(int)statusCode andResponseFileName:(NSString*)fileName {
    [self addStubWithPOSTRequestPath:path responseHandler:[self handlerResponseWithStatusCode:statusCode andFileName:fileName]];
}

+ (void)addStubWithPOSTRequestPath:(NSString*)path responseHandler:(OHHTTPStubsResponseBlock)handler {
    [self addStubWithRequestPath:path matchingHttpMethod:@"POST" responseHandler:handler];
}

#pragma mark PUT

+ (void)addStubWithPUTRequestPath:(NSString*)path statusCode:(int)statusCode andResponseString:(NSString*)response {
    [self addStubWithPUTRequestPath:path responseHandler:[self handlerResponseWithStatusCode:statusCode andResponseString:response]];
}

+ (void)addStubWithPUTRequestPath:(NSString*)path responseHandler:(OHHTTPStubsResponseBlock)handler {
    [self addStubWithRequestPath:path matchingHttpMethod:@"PUT" responseHandler:handler];
}

#pragma mark DELETE

+ (void)addStubWithDELETERequestPath:(NSString*)path statusCode:(int)statusCode andResponseString:(NSString*)response {
    [self addStubWithDELETERequestPath:path responseHandler:[self handlerResponseWithStatusCode:statusCode andResponseString:response]];
}

+ (void)addStubWithDELETERequestPath:(NSString*)path responseHandler:(OHHTTPStubsResponseBlock)handler {
    [self addStubWithRequestPath:path matchingHttpMethod:@"DELETE" responseHandler:handler];
}

#pragma mark Stub registration

+ (void)addStubWithRequestPath:(NSString*)path matchingHttpMethod:(NSString*)httpMethod responseHandler:(OHHTTPStubsResponseBlock)handler {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString *normalizeRequestPath = [request.URL.path stringByReplacingOccurrencesOfString:@"/rest/" withString:@""];
        return [normalizeRequestPath isEqualToString:path] && [request.HTTPMethod isEqualToString:httpMethod];
    } withStubResponse:handler];
}

+ (void)addStubWithRequestPath:(NSString *)path
                        method:(NSString *)httpMethod
                    statusCode:(int)statusCode
                   andFileName:(NSString *)fileName
           requiringParameters:(NSArray<NSString *> *)mandatoryParameters {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        NSString *normalizeRequestPath = [request.URL.path stringByReplacingOccurrencesOfString:@"/rest/" withString:@""];
        if ([normalizeRequestPath isEqualToString:path] &&
            [request.HTTPMethod isEqualToString:httpMethod]) {
            
            NSString *urlParameters = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
            NSDictionary *params = urlParameters.dictionary;
            for (NSString *mandatoryParameter in mandatoryParameters) {
                id value = params[mandatoryParameter];
                if (value == nil || [value isEqualToString:@"(null)"]) {
                    return NO;
                }
            }
            return YES;
        } else {
            return NO;
        }
    } withStubResponse:[self handlerResponseWithStatusCode:statusCode andFileName:fileName]];
}
@end

#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
@implementation OHHTTPStubsResponse (Factory)
+ (OHHTTPStubsResponse *)emptyJSONArray {
    return [OHHTTPStubsResponse responseWithJSONObject:@[] statusCode:200 headers:nil];
}

@end
