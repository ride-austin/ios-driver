//
//  CarSelectionDataSourceTest.m
//  RideDriver
//
//  Created by Roberto Abreu on 26/12/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CarSelectionHeader.h"
#import "CarSelectionDataSource.h"

static NSString * const kCarSelectionHeaderIdentifier = @"CarSelectionHeader";

@interface CarSelectionDataSourceTest : XCTestCase

@property (nonatomic) CarSelectionDataSource *carSelectionDataSource;
@property (nonatomic) Car *carSelected;
@property (nonatomic) Car *carNotSelected;
@property (nonatomic) UITableView *tableViewMock;

@end

@implementation CarSelectionDataSourceTest

- (void)setUp {
    [super setUp];
    self.carSelectionDataSource = [[CarSelectionDataSource alloc] initWithDelegate:nil andCityDetail:nil];
    
    self.tableViewMock = [[UITableView alloc] init];
    [self.tableViewMock registerNib:[UINib nibWithNibName:kCarSelectionHeaderIdentifier bundle:nil] forHeaderFooterViewReuseIdentifier:kCarSelectionHeaderIdentifier];
    self.tableViewMock.dataSource = self.carSelectionDataSource;
    self.tableViewMock.delegate = self.carSelectionDataSource;
    
    NSDictionary * params = @{
                               @"id"               : @1,
                               @"color"            : @"Black",
                               @"license"          : @"ASDF123",
                               @"make"             : @"BMW",
                               @"model"            : @"X7",
                               @"selected"         : @YES,
                               @"year"             : @"1999",
                               @"photoUrl"         : @"www.google.com",
                               @"inspectionStatus" : @"APPROVED",
                               @"inspectionNotes"  : @"Test notes"
                             };
    
    NSError *error = nil;
    self.carSelected = [MTLJSONAdapter modelOfClass:[Car class] fromJSONDictionary:params error:&error];
    
    self.carNotSelected = [MTLJSONAdapter modelOfClass:[Car class] fromJSONDictionary:params error:&error];
    self.carNotSelected.isSelected = NO;

    self.carSelectionDataSource.cars = @[self.carSelected,self.carNotSelected];
}

- (void)testTableViewInitialized {
    XCTAssertNotNil(self.tableViewMock, @"TableView should not be nil");
    XCTAssertNotNil(self.tableViewMock.dataSource, @"TableView datasource should not be nil");
    XCTAssertNotNil(self.tableViewMock.delegate, @"TableView delegate should not be nil");
}

- (void)testCarModelIsNotNil {
    XCTAssertNotNil(self.carSelected, @"Car initialization failed");
    XCTAssertNotNil(self.carNotSelected, @"Car initialization failed");
}

- (void)testCarModelProperties {
    XCTAssertEqualObjects(self.carSelected.modelID, @1);
    XCTAssertEqualObjects(self.carSelected.photoUrl, [NSURL URLWithString:@"www.google.com"]);
    XCTAssertEqualObjects(self.carSelected.color, @"Black");
    XCTAssertEqualObjects(self.carSelected.license, @"ASDF123");
    XCTAssertEqualObjects(self.carSelected.inspectionStatus, @"APPROVED");
    XCTAssertEqualObjects(self.carSelected.inspectionNotes, @"Test notes");
    XCTAssertEqualObjects(self.carSelected.make, @"BMW");
    XCTAssertEqualObjects(self.carSelected.model, @"X7");
    XCTAssertEqualObjects(self.carSelected.year, @"1999");
    XCTAssertTrue(self.carSelected.isSelected, @"This car should be selected");
    XCTAssertFalse(self.carNotSelected.isSelected, @"This car should not be selected");
}

- (void)testNumberOfCars {
    NSInteger numberOfCars = [self.carSelectionDataSource numberOfSectionsInTableView:self.tableViewMock];
    XCTAssertEqual(numberOfCars, 2, @"Should be 2 cars in DataSource");
}

- (void)testNumberOfOptionsInMenu {
    NSInteger numberOfItemsInMenu = [self.carSelectionDataSource tableView:self.tableViewMock numberOfRowsInSection:0];
    XCTAssertEqual(numberOfItemsInMenu, 2, @"Should be 2 Items in menu");
}

- (void)testSectionHeaderCarName {
    CarSelectionHeader *carSelectionHeader = (CarSelectionHeader*)[self.carSelectionDataSource tableView:self.tableViewMock viewForHeaderInSection:0];
    NSString *carNameToTest = carSelectionHeader.carName.text;
    XCTAssertEqualObjects(carNameToTest, self.carSelected.carName, @"Car name are not equals");
}

- (void)testSectionHeaderSelectedColor {
    CarSelectionHeader *carSelectionHeader = (CarSelectionHeader*)[self.carSelectionDataSource tableView:self.tableViewMock viewForHeaderInSection:0];
    UIColor *selectedColor = [UIColor colorWithRed:2.0f/255.0f green:167.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
    UIColor *selectedColorToTest = carSelectionHeader.carName.textColor;
    XCTAssertEqualObjects(selectedColorToTest, selectedColor, @"Selected color is not correct");
}

- (void)testSectionHeaderNotSelectedColor {
    CarSelectionHeader *carSelectionHeader = (CarSelectionHeader*)[self.carSelectionDataSource tableView:self.tableViewMock viewForHeaderInSection:1];
    UIColor *unselectedColor = [UIColor colorWithRed:40.0/255.0 green:50.0/255.0 blue:60.0/255.0 alpha:1.0f];
    UIColor *unSelectedColorToTest = carSelectionHeader.carName.textColor;
    XCTAssertEqualObjects(unSelectedColorToTest, unselectedColor, @"Unselected color is not correct");
}

- (void)testSectionHeaderSelectedImage {
    CarSelectionHeader *carSelectionHeader = (CarSelectionHeader*)[self.carSelectionDataSource tableView:self.tableViewMock viewForHeaderInSection:0];
    UIImage *selectedImage = [UIImage imageNamed:@"active"];
    UIImage *selectedImageToTest = carSelectionHeader.btnSelection.currentImage;
    XCTAssertEqualObjects(selectedImageToTest, selectedImage, @"Selected image is not correct");
}

- (void)testSectionHeaderNotSelectedImage {
    CarSelectionHeader *carSelectionHeader = (CarSelectionHeader*)[self.carSelectionDataSource tableView:self.tableViewMock viewForHeaderInSection:1];
    UIImage *unselectedImage = [UIImage imageNamed:@"oval"];
    UIImage *unSelectedImageToTest = carSelectionHeader.btnSelection.currentImage;
    XCTAssertEqualObjects(unSelectedImageToTest, unselectedImage, @"Unselected image is not correct");
}

@end
