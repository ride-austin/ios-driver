//
//  CarSelectionItem.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 10/2/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "Car.h"

typedef void(^DidTapCar)(Car *car);

@interface CarSelectionItem : NSObject

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) DidTapCar didTapCarBlock;

+ (instancetype)itemWithTitle:(NSString *)title andDidTapCarBlock:(DidTapCar)didTapCarBlock;

@end


