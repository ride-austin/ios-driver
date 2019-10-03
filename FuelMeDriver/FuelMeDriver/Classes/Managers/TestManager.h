//
//  TestManager.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/15/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AutomatedTestType) {
    /**
     *  @brief no automated tests running
     */
    ATTNoTest    = 0,
    /**
     *  @brief when you need to clear authentication token
     */
    ATTNoAuth    = 1,
    ATTSkipLogin = 2,
    /**
     *  @brief when you need to start without internet
     */
    ATTNoNetwork = 3
};

@interface TestManager : NSObject

+ (AutomatedTestType)testType;

@end
