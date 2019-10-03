//
//  ADMenuItem.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 8/16/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DidTapCell)(UITableViewCell *);

@interface ADMenuItem : NSObject

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) DidTapCell didTapCellBlock;

+ (instancetype)itemWithTitle:(NSString *)title andDidTapCellBlock:(DidTapCell)didTapCellBlock;
- (instancetype)initWithTitle:(NSString *)title andDidTapCellBlock:(DidTapCell)didTapCellBlock;

@end
