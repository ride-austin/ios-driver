//
//  NSDictionary+urlEncodedString.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/20/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "NSDictionary+urlEncodedString.h"

@implementation NSDictionary (urlEncodedString)
-(NSString *)urlEncodedString {
    NSMutableArray *parts = [NSMutableArray new];
    for (NSString *key in self.allKeys) {
        id value = self[key];
        NSString *part = [NSString stringWithFormat:@"%@=%@", key, value];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"&"];
}
@end
