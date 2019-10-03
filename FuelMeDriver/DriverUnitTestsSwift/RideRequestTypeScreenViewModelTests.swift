//
//  RideRequestTypeScreenViewModelTests.swift
//  DriverUnitTestsSwift
//
//  Created by Theodore Gonzalez on 7/15/18.
//  Copyright © 2018 FuelMe LLC. All rights reserved.
//

import XCTest
@testable import RideDriverTest___Enterprise
final class RideRequestTypeScreenViewModelTests: XCTestCase {
    fileprivate var configurationManager: ConfigurationManager = ConfigurationManager.shared()
    fileprivate var sessionManager: RASessionManager = RASessionManager.shared()
    fileprivate var viewModel: RideRequestTypeScreenViewModelTests?
    override func setUp() {
        super.setUp()
        setupCityCarTypes()
        setupDriverTypes()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}

private extension RideRequestTypeScreenViewModelTests {
    func setupCityCarTypes() {
        let json:[Any] = Data.extractJSON(fromResource: "CAR_TYPES_200", bundleClass: self.classForCoder)
        configurationManager.global.carTypes = try! MTLJSONAdapter.models(of: RACarCategoryDataModel.self, fromJSONArray: json) as! [RACarCategoryDataModel]
    }
    func setupDriverTypes() {
        let json:[Any] = Data.extractJSON(fromResource: "DRIVER_TYPES_200", bundleClass: self.classForCoder)
        configurationManager.global.driverTypes = try! MTLJSONAdapter.models(of: RADriverType.self, fromJSONArray: json) as! [RADriverType]
    }
}

extension Data {
    static func extractJSON<T>(fromResource resourceName:String, bundleClass: AnyClass) -> T {
        let path = Bundle(for: bundleClass).path(forResource: resourceName, ofType: "json")
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
        return jsonResult as! T
    }
}

//- (void)setUp {
//    [super setUp];
//    [self configureCityCarTypes];
//    [self configureDriverTypes];
//    [self configureTestDriverWithGrantedTypes:@[@"WOMEN_ONLY"]];
//
//    self.viewModel = [RideRequestTypeScreenViewModel viewModelWithDelegate:nil];
//}
//
//- (void)configureTestDriverWithGrantedTypes:(NSArray<NSString*> *)grantedTypes {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"CURRENT_DRIVER_200" ofType:@"json"];
//    NSMutableDictionary *driverDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
//                                                               options:NSJSONReadingMutableContainers error:nil];
//    driverDict[@"grantedDriverTypes"] = grantedTypes;
//
//    RADriverDataModel *driverDataModel = [MTLJSONAdapter modelOfClass:[RADriverDataModel class] fromJSONDictionary:driverDict error:nil];
//
//    NSDictionary *sessionDict = @{ @"driver" : driverDataModel };
//    [RASessionManager shared].currentSession = [[RASessionDataModel alloc] initWithDictionary:sessionDict error:nil];
//    [RASessionManager shared].currentSession.isOnlyFemaleDriverEnabled = NO;
//    [RASessionManager shared].currentSession.userCarTypes = @[@"REGULAR", @"SUV", @"LUXURY", @"PREMIUM"];
//}
//
//- (void)configureSelectedRideTypes:(NSArray<NSString *> *)selectedRideTypes {
//    [RASessionManager shared].currentSession.userCarTypes = selectedRideTypes;
//    [self.viewModel updateCarTypes];
//}
//
//- (void)configureActiveRideTypes:(NSArray<NSString *> *)activeRideTypes {
//    [RASessionManager shared].currentSession.driver.selectedCar.carCategories = activeRideTypes;
//    [self.viewModel updateCarTypes];
//}
//
//#pragma mark - Tests
//
//- (void)testRideRequestTypeScreenTitle {
//    XCTAssertEqualObjects(self.viewModel.title, @"Ride Request Type");
//}
//
//- (void)testSelectedCarName {
//    XCTAssertEqualObjects(self.viewModel.displayCarName, @"Alfa Romeo Giulia");
//}
//
//- (void)testShouldShowFemaleDriverMode {
//    //Test Driver has granted WOMEN_ONLY
//    XCTAssertTrue(self.viewModel.shouldShowFemaleDriverMode);
//}
//
//- (void)testShouldNotShowFemaleDriverMode {
//    [self configureTestDriverWithGrantedTypes:@[]];
//    XCTAssertFalse(self.viewModel.shouldShowFemaleDriverMode);
//
//    [self configureTestDriverWithGrantedTypes:nil];
//    XCTAssertFalse(self.viewModel.shouldShowFemaleDriverMode);
//}
//
//- (void)testSelectionDescriptionAllCarTypesSelectedAndFemaleModeNotGranted {
//    [self configureTestDriverWithGrantedTypes:nil];
//    NSArray *categories = @[@"REGULAR", @"SUV", @"LUXURY", @"PREMIUM"];
//    [self configureActiveRideTypes:categories];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSTANDARD + SUV + PREMIUM + LUXURY\n\nAll car types are selected");
//}
//
//- (void)testSelectionDescriptionAllCarTypesSelectedAndFemaleModeGranted {
//    NSArray *categories = @[@"REGULAR", @"SUV", @"LUXURY", @"PREMIUM"];
//    [self configureActiveRideTypes:categories];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSTANDARD + SUV + PREMIUM + LUXURY\nand\nSTANDARD + SUV + PREMIUM + LUXURY\nfemale driver requests\n\nAll car types are selected");
//}
//
//- (void)testSelectionDescriptionAllCarTypesSelectedWithWomanOnlyRideEnabled {
//    self.viewModel.isOnlyFemaleDriverEnabled = YES;
//    NSArray *categories = @[@"REGULAR", @"SUV", @"LUXURY", @"PREMIUM"];
//    [self configureActiveRideTypes:categories];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSTANDARD + SUV + PREMIUM + LUXURY\nfemale driver requests ONLY\n\nAll car types are selected");
//}
//
//- (void)testDisableAllCarTypes {
//    NSArray *categories = @[@"REGULAR", @"SUV", @"LUXURY", @"PREMIUM"];
//    [self configureSelectedRideTypes:categories];
//    [self configureActiveRideTypes:categories];
//    for (int i = 0; i < [ConfigurationManager shared].global.carTypes.count; i++) {
//        [self.viewModel didSelectIndex:i];
//    }
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Please select car type");
//}
//
//- (void)testSelectionDescriptionWithFemaleModeGranted {
//    [self configureSelectedRideTypes:@[@"SUV", @"PREMIUM"]];
//    [self configureActiveRideTypes:@[@"REGULAR", @"SUV", @"PREMIUM", @"LUXURY"]];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSUV + PREMIUM\nand\nSUV + PREMIUM\nfemale driver requests\n\nSelect or register for other car categories to receive ride requests in those categories.");
//
//    //Activate REGULAR
//    [self.viewModel didSelectIndex:0];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSTANDARD + SUV + PREMIUM\nand\nSTANDARD + SUV + PREMIUM\nfemale driver requests\n\nSelect or register for other car categories to receive ride requests in those categories.");
//
//    //Disable PREMIUM
//    [self.viewModel didSelectIndex:2];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSTANDARD + SUV\nand\nSTANDARD + SUV\nfemale driver requests\n\nSelect or register for other car categories to receive ride requests in those categories.");
//}
//
//- (void)testSelectionDescriptionWithFemaleModeNotGranted {
//    [self configureTestDriverWithGrantedTypes:nil];
//    [self configureSelectedRideTypes:@[@"SUV", @"PREMIUM"]];
//    [self configureActiveRideTypes:@[@"REGULAR", @"SUV", @"PREMIUM", @"LUXURY"]];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSUV + PREMIUM\n\nSelect or register for other car categories to receive ride requests in those categories.");
//
//    //Activate REGULAR
//    [self.viewModel didSelectIndex:0];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSTANDARD + SUV + PREMIUM\n\nSelect or register for other car categories to receive ride requests in those categories.");
//
//    //Disable PREMIUM
//    [self.viewModel didSelectIndex:2];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSTANDARD + SUV\n\nSelect or register for other car categories to receive ride requests in those categories.");
//}
//
//- (void)testSelectionDescriptionWithWomanOnlyRideEnabled {
//    self.viewModel.isOnlyFemaleDriverEnabled = YES;
//    [self configureSelectedRideTypes:@[@"SUV", @"PREMIUM"]];
//    [self configureActiveRideTypes:@[@"REGULAR", @"SUV", @"PREMIUM", @"LUXURY"]];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSUV + PREMIUM\nfemale driver requests ONLY\n\nSelect or register for other car categories to receive ride requests in those categories.");
//
//    //Activate REGULAR
//    [self.viewModel didSelectIndex:0];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSTANDARD + SUV + PREMIUM\nfemale driver requests ONLY\n\nSelect or register for other car categories to receive ride requests in those categories.");
//
//    //Disable PREMIUM
//    [self.viewModel didSelectIndex:2];
//    XCTAssertEqualObjects(self.viewModel.selectionDescription, @"Your current ride request type is now set to the following categories. You are set to receive:\n\nSTANDARD + SUV\nfemale driver requests ONLY\n\nSelect or register for other car categories to receive ride requests in those categories.");
//}
//
//- (void)testThatDoesntAllowSavingWithoutSelectingACategory {
//    NSArray *categories = @[@"REGULAR", @"SUV", @"LUXURY", @"PREMIUM"];
//    [self configureSelectedRideTypes:categories];
//    [self configureActiveRideTypes:categories];
//    for (int i = 0; i < [ConfigurationManager shared].global.carTypes.count; i++) {
//        [self.viewModel didSelectIndex:i];
//    }
//
//    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Error generated"];
//    [self.viewModel didSaveWithCompletion:^(NSString *errorMessage) {
//        XCTAssertEqualObjects(errorMessage, @"Please select at least one category");
//        [expectation fulfill];
//    }];
//
//    [self waitForExpectations:@[expectation] timeout:5];
//}
//
//- (void)testCanSaveWhenFemaleDriverChanged {
//    [RASessionManager shared].currentSession.isOnlyFemaleDriverEnabled = YES;
//    XCTAssertTrue(self.viewModel.canSave);
//}
//
//- (void)testCanSaveWhenCategoriesChanged {
//    [self configureSelectedRideTypes:@[@"SUV", @"PREMIUM"]];
//    [self configureActiveRideTypes:@[@"REGULAR", @"SUV", @"PREMIUM", @"LUXURY"]];
//    XCTAssertFalse(self.viewModel.canSave);
//
//    [self.viewModel didSelectIndex:0];
//    XCTAssertTrue(self.viewModel.canSave);
//}
