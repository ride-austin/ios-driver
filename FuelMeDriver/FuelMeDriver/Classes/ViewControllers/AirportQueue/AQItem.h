//
//  AQItem.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AQItem : NSObject

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSString *carCategory;

+ (instancetype)itemWithCarCategory:(NSString *)carCategory displayName:(NSString *)displayName imageURL:(NSURL *)imageURL;
- (void)setPosition:(id)position;
- (void)setTotal:(id)total;
- (NSString *)displayPosition;
- (NSString *)displayTotal;
- (BOOL)hasPosition;

@end
