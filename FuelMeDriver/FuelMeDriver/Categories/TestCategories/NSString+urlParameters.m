//
//  NSString+urlParameters.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "NSString+urlParameters.h"

@implementation NSString (urlParameters)
- (NSDictionary *)dictionary {
    NSMutableDictionary *queryStringDictionary = [NSMutableDictionary new];
    NSArray *urlComponents = [self componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key   = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject  stringByRemovingPercentEncoding];
        queryStringDictionary[key] = value;
    }
    return queryStringDictionary;
}
@end
