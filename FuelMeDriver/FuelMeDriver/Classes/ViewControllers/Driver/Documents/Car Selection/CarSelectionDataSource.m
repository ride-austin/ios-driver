//
//  CarSelectionDataSource.m
//  RideDriver
//
//  Created by Roberto Abreu on 26/12/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "CarSelectionDataSource.h"

#import "CarPhotoUpdateMenuViewController.h"
#import "CarSelectionHeader.h"
#import "CarSelectionItem.h"
#import "CarSelectionItemCell.h"
#import "InsuranceDocumentViewController.h"
#import "NSString+Utils.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator_for_SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

#define kSelectedColor [UIColor colorWithRed:2.0f/255.0f green:167.0f/255.0f blue:249.0f/255.0f alpha:1.0f]
#define kUnselectedColor [UIColor colorWithRed:40.0/255.0 green:50.0/255.0 blue:60.0/255.0 alpha:1.0f]

static NSString * const kUpdateInsurance = @"Update Insurance";
static NSString * const kUpdateCarPhotos = @"Update Car Photos";

@interface CarSelectionDataSource ()

@property (nonatomic, strong) NSArray<NSArray<CarSelectionItem *> *> *sections;

@end

@implementation CarSelectionDataSource

- (instancetype)initWithDelegate:(id<CarSelectionDelegate>)delegate
                   andCityDetail:(RACityDetail *)cityDetail {
    if (self = [super init]) {
        self.cityDetail = cityDetail;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - TABLEVIEW DATASOURCE & DELEGATE

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    Car *car = self.cars[section];
    CarSelectionHeader *selectionHeader = (CarSelectionHeader*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:CarSelectionHeader.className];
    
    selectionHeader.carName.text = car.carName;
    selectionHeader.carName.textColor = (car.isSelected ? kSelectedColor : kUnselectedColor);
    [selectionHeader.imgCar setImageWithURL:car.photoUrl
                           placeholderImage:[UIImage imageNamed:@"car_premium"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    NSString *imgName = car.isSelected ? @"active" : @"oval";
    [selectionHeader.btnSelection setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [selectionHeader.btnSelection setTag:section];
    [selectionHeader.btnSelection addTarget:self action:@selector(carSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    return selectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CarSelectionItem *item = self.sections[indexPath.section][indexPath.row];
    CarSelectionItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CarSelectionItemCell.className forIndexPath:indexPath];
    cell.textLabel.text = item.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Car *car = self.cars[indexPath.section];
    CarSelectionItem *item = self.sections[indexPath.section][indexPath.row];
    item.didTapCarBlock(car);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CarSelectionDelegate

- (void)carSelected:(UIButton*)sender {
    Car *carTapped = self.cars[sender.tag];
    
    if (carTapped.isSelected) {
        return;
    }
    
    [self.delegate didSelectCar:carTapped];
}

#pragma mark - Car mapping menu

- (void)setCars:(NSArray<Car *> *)cars {
    _cars = cars;
    
    __weak __typeof__(self) weakself = self;
    NSMutableArray<NSMutableArray<CarSelectionItem *> *> *mSections = [NSMutableArray new];
    
    for (Car *car in self.cars) {
        NSMutableArray<CarSelectionItem *>*rows = [NSMutableArray new];
        [rows addObject:[CarSelectionItem itemWithTitle:[kUpdateInsurance localized] andDidTapCarBlock:^(Car *car) {
            [weakself.delegate didSelectInsuranceOptionWithCar:car];
        }]];
        [rows addObject:[CarSelectionItem itemWithTitle:[kUpdateCarPhotos localized] andDidTapCarBlock:^(Car *car) {
            [weakself.delegate didSelectUpdateCarPhotoOptionWithCar:car];
        }]];
        
        if ([car.year intValue] <= [self.cityDetail.inspectionSticker.minYearRequired intValue] && self.cityDetail.inspectionSticker.isEnabled) {
            NSString *title = [NSString stringWithFormat:[@"Update %@" localized], self.cityDetail.inspectionSticker.navBarTitle];
            [rows addObject:[CarSelectionItem itemWithTitle:title andDidTapCarBlock:^(Car *car) {
                [weakself.delegate didSelectInspectionStikerWithCar:car];
            }]];
        }
        [mSections addObject:rows];
    }
    
    self.sections = mSections;
}

@end
