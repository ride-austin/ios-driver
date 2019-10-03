//
//  CityTests.m
//  RideDriver
//
//  Created by Carlos Alcala on 11/22/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RACity.h"
#import "UIColor+HexUtils.h"

@interface CityTests : XCTestCase

@property (strong, nonatomic) RACity *cityObject;
@property (strong, nonatomic) RACity *selectedCity;
@property (strong, nonatomic) NSArray<RACity*> *cities;

@end

@implementation CityTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [self loadCityData];
    
}

- (void)loadCityData {
    
    NSArray* data = @[@{@"name" : @"Austin",@"id" : @"city001", @"url" : @"http://www.rideaustin.com/AustinURL" }, @{@"name" : @"Houston",@"id" : @"city002", @"url" : @"http://www.rideaustin.com/HoustonURL" }];
    
    NSMutableArray* options = [NSMutableArray new];
    
    for (NSDictionary *json in data) {
        RACity * city = [[RACity alloc] initWithJSON:json];
        [options addObject:city];
    }
    
    self.cities = [NSArray arrayWithArray:options];
    
    NSDictionary* json = @{@"name" : @"Austin",@"id" : @"city001", @"url" : @"http://www.rideaustin.com/AustinURL" };
    
    self.cityObject = [[RACity alloc] initWithJSON:json];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCityModelIsNotNil {
    XCTAssertNotNil(self.cityObject, @"City object init failed");
}

- (void)testCityModelProperties {
    XCTAssertEqual(self.cityObject.cityID, @"city001");
    XCTAssertEqual(self.cityObject.name, @"Austin");
    XCTAssertEqual(self.cityObject.imageURL, @"http://www.rideaustin.com/AustinURL");
}

- (void)testCityModelFunctions {
    //test functions objets
    XCTAssertEqualObjects(self.cityObject.logoImage, [UIImage imageNamed:@"logoRideAustin"], @"LogoImage is not correct");
    XCTAssertEqualObjects(self.cityObject.splashImage, [UIImage imageNamed:@"splashAustin"], @"SplashImage is not correct");
    XCTAssertEqualObjects([self.cityObject colorByCity:Foreground], [UIColor colorWithHex:@"#2282F2"], @"Foreground Color is not correct");
    XCTAssertEqualObjects([self.cityObject colorByCity:Background], [UIColor clearColor], @"Background Color is not correct");
    XCTAssertEqualObjects([self.cityObject colorByCity:SecondaryText], [UIColor whiteColor], @"Secondary Foreground Color is not correct");
    XCTAssertEqualObjects([self.cityObject colorByCity:SecondaryBack], [UIColor colorWithHex:@"#2282F2"], @"Secondary Background Color is not correct");
    XCTAssertEqual(self.cityObject.cityType, Austin);
}

- (void)testSelectedCity {
    XCTAssertEqual(self.cities.count, 2);
    //selected city for testing
    self.selectedCity = self.cities[1];
    XCTAssertNotNil(self.selectedCity, @"City object init failed");
    XCTAssertEqual(self.selectedCity.cityID, @"city002");
    XCTAssertEqual(self.selectedCity.name, @"Houston");
    XCTAssertEqual(self.selectedCity.imageURL, @"http://www.rideaustin.com/HoustonURL");
    XCTAssertEqualObjects(self.selectedCity.logoImage, [UIImage imageNamed:@"logoRideHouston"], @"LogoImage is not correct");
    XCTAssertEqualObjects(self.selectedCity.splashImage, [UIImage imageNamed:@"splashHouston"], @"SplashImage is not correct");
    XCTAssertEqualObjects([self.selectedCity colorByCity:Foreground], [UIColor whiteColor], @"Color By City is not correct");
    XCTAssertEqualObjects([self.selectedCity colorByCity:Background], [UIColor colorWithHex:@"#2282F2"], @"Background Color By City is not correct");
}

@end
