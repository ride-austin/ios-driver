//
//  RAPollingManager.h
//  RideDriver
//
//  Created by Roberto Abreu on 7/21/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RAPollingManager <NSObject>

- (void)start;
- (void)stop;

@end
