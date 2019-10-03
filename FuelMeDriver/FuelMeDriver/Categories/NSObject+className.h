//
//  NSObject+className.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (className)
+(NSString *)className;
-(NSString *)className;
+(NSString *)segueTo:(Class)className;
@end
