//
//  NSObject+className.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NSObject+className.h"

@implementation NSObject (className)
+(NSString *)className {
    return NSStringFromClass([self class]);
}
-(NSString *)className {
    return NSStringFromClass([self class]);
}
+(NSString *)segueTo:(Class)className {
    NSMutableString *identifier = [[NSMutableString alloc] initWithString:@"segue_"];
    [identifier appendString:NSStringFromClass([self class])];
    [identifier appendString:@"_"];
    [identifier appendString:NSStringFromClass(className)];
    return identifier.copy;
}
@end
