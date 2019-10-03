//
//  CarSelectionDataSource.h
//  RideDriver
//
//  Created by Roberto Abreu on 26/12/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Car.h"
#import "RACityDetail.h"

@protocol CarSelectionDelegate

- (void)didSelectInsuranceOptionWithCar:(Car*)car;
- (void)didSelectUpdateCarPhotoOptionWithCar:(Car*)car;
- (void)didSelectInspectionStikerWithCar:(Car*)car;
- (void)didSelectCar:(Car*)car;

@end

@interface CarSelectionDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<CarSelectionDelegate> delegate;
@property (nonatomic, strong) NSArray<Car*> *cars;
@property (nonatomic, strong) RACityDetail *cityDetail;

- (instancetype)initWithDelegate:(id<CarSelectionDelegate>)delegate andCityDetail:(RACityDetail*)cityDetail;

@end
