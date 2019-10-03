//
//  DirectConnectUnitTests.m
//  DriverUITests
//
//  Created by Theodore Gonzalez on 12/10/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConfigGlobal.h"
#import "RADriverDataModel.h"
#import "RASideMenu.h"
#import "RASideMenuItem.h"
#import "NSDictionary+JSON.h"
@interface DirectConnectUnitTests : XCTestCase

@property (nonatomic) RASideMenu *sideMenu;
@property (nonatomic) ConfigGlobal *global;
@property (nonatomic) RADriverDataModel *driver;
@end

@implementation DirectConnectUnitTests

- (void)setUp {
    [super setUp];

    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    id jsonConfig = [NSDictionary jsonFromResourceName:@"AustinConfigGlobal" bundle:bundle error:nil];
    id jsonDriver = [NSDictionary jsonFromResourceName:@"CURRENT_DRIVER_200" bundle:bundle error:nil];
    self.global = [MTLJSONAdapter modelOfClass:ConfigGlobal.class fromJSONDictionary:jsonConfig error:&error];
    self.driver = [MTLJSONAdapter modelOfClass:RADriverDataModel.class fromJSONDictionary:jsonDriver error:&error];
    
    self.sideMenu = [RASideMenu configureWithPresenter:nil];
}

- (void)tearDown {
    [super tearDown];
}

//https://testrail.devfactory.com/index.php?/tests/view/17118484
- (void)testShowIfProvided_17118484 {
    self.global.configDirectConnect.isEnabled = YES;
    [self.driver updateChauffeurPermit:YES];
    [self.sideMenu updateMenuItemsWithConfig:self.global andDriver:self.driver];
    [self passWhenDirectConnectIsFound];
    
    self.global.configDirectConnect.isEnabled = NO;
    [self.sideMenu updateMenuItemsWithConfig:self.global andDriver:self.driver];
    [self passWhenDirectConnectIsNotFound];
}

//https://testrail.devfactory.com/index.php?/tests/view/17118485
- (void)testHideIfNotProvided_17118485 {
    self.global.configDirectConnect.isEnabled = YES;
    [self.driver updateChauffeurPermit:NO];
    [self.sideMenu updateMenuItemsWithConfig:self.global andDriver:self.driver];
    [self passWhenDirectConnectIsNotFound];
}

#pragma mark - Helpers
- (void)passWhenDirectConnectIsFound {
    for (RASideMenuItem *item in self.sideMenu.menuItems) {
        if ([item.title isEqualToString:@"Direct Connect"] &&
            [item.iconName isEqualToString:@"direct-connect-icon"]) {
            return;
        }
    }
    XCTFail("Expecting direct connect but not found");
}

- (void)passWhenDirectConnectIsNotFound {
    for (RASideMenuItem *item in self.sideMenu.menuItems) {
        XCTAssertNotEqualObjects(item.title, @"Direct Connect");
        XCTAssertNotEqualObjects(item.iconName, @"direct-connect-icon");
    }
}

@end

