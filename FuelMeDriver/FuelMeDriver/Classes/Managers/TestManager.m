//
//  TestManager.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/15/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "TestManager.h"

@implementation TestManager

+ (AutomatedTestType)testType {
    NSDictionary *env = [NSProcessInfo processInfo].environment;
    if ([env[@"AUTOMATION"] isEqualToString:@"ATTNoAuth"]) {
        return ATTNoAuth;
    }
    else if ([env[@"AUTOMATION"] isEqualToString:@"ATTNoNetwork"]){
        return ATTNoNetwork;
    }
    else {
        return ATTNoTest;
    }
}

@end
