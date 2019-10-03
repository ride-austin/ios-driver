//
//  RARideCacheManagerDelegate.h
//  RideDriver
//
//  Created by Roberto Abreu on 1/5/18.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RARideCacheManagerDelegate <NSObject>

- (void)willFlushRideCacheData;
- (void)didFlushRideCacheDataSuccessfully:(BOOL)success;

@end
