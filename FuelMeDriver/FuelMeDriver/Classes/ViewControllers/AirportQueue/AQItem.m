//
//  AQItem.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/15/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "AQItem.h"
#import "NSString+Utils.h"

@interface AQItem()

@property (nonatomic) id position;
@property (nonatomic) id total;

@end

@implementation AQItem

+ (instancetype)itemWithCarCategory:(NSString *)carCategory displayName:(NSString *)displayName imageURL:(NSURL *)imageURL {
    AQItem *item = [AQItem new];
    item.carCategory = carCategory;
    item.displayName = displayName;
    item.imageURL    = imageURL;
    return item;
}

- (void)setPosition:(id)position {
    _position = position;
}

- (void)setTotal:(id)total {
    _total = total;
}

- (NSString *)displayPosition {
    if (([_position isKindOfClass:[NSString class]] && [_position length] > 0) ||
         [_position isKindOfClass:[NSNumber class]]) {
        long position = [_position integerValue] + 1;
        if (position == 1) {
            return [@"NEXT" localized];
        } else {
            return [NSString stringWithFormat:@"%ld", position];
        }
    }
    return [@"N/A" localized];
}

- (NSString *)displayTotal {
    return _total ? [NSString stringWithFormat:@"%@",_total] : @"-";
}

- (BOOL)hasPosition {
    return [[@"N/A" localized] isEqualToString:self.displayPosition] == NO;
}

@end
