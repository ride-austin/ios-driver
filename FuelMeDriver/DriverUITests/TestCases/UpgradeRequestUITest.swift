//
//  UpgradeRequestUITest.swift
//  RideDriver
//
//  Created by Roberto Abreu on 7/3/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class UpgradeRequestUITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUpgradeOptionEnabledIsShown() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        XCTAssertTrue(testFlow.locationVCInspector.upgradeToSUVOption.exists)
    }
    
    func testUpgradeOptionEnabledInStandardIsNotShownInOtherCategories() {
        let scenario: EventsScenario = .IncomingRideRequestPerCategory
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        //SUV Request
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        testFlow.pressFloatingButton()
        XCTAssertFalse(testFlow.locationVCInspector.upgradeToSUVOption.exists)
        testFlow.pressFloatingButton()
        testFlow.pressCancelTrip()
        
        //Premium Request
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        testFlow.pressFloatingButton()
        XCTAssertFalse(testFlow.locationVCInspector.upgradeToSUVOption.exists)
        testFlow.pressFloatingButton()
        testFlow.pressCancelTrip()
        
        //Luxury Request
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        testFlow.pressFloatingButton()
        XCTAssertFalse(testFlow.locationVCInspector.upgradeToSUVOption.exists)
    }
    
    func testUpgradeOptionDisabledNotShown() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue, "MAP_UPGRADE_REQUEST_DISABLED"])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        testFlow.pressFloatingButton()
        XCTAssertFalse(testFlow.locationVCInspector.upgradeToSUVOption.exists)
    }
    
    func testUpgradeOptionNotShownAfterRideStarted() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        XCTAssertTrue(testFlow.locationVCInspector.upgradeToSUVOption.exists)
        testFlow.pressFloatingButton()
        
        testFlow.pressArrived()
        
        testFlow.pressFloatingButton()
        XCTAssertTrue(testFlow.locationVCInspector.upgradeToSUVOption.exists)
        testFlow.pressFloatingButton()
        
        testFlow.pressBeginTrip()
        testFlow.pressFloatingButton()
        XCTAssertFalse(testFlow.locationVCInspector.upgradeToSUVOption.exists)
    }
    
    func testUpgradeRequestWhileOnWay() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()

        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.pressCloseUpgrade()
        
        testFlow.pressFloatingButton()
        XCTAssertTrue(testFlow.locationVCInspector.upgradeToSUVRequestedOption.exists)
    }
    
    func testUpgradeRequestAfterArrive() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressArrived()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()
        
        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.pressCloseUpgrade()
        
        testFlow.pressFloatingButton()
        XCTAssertTrue(testFlow.locationVCInspector.upgradeToSUVRequestedOption.exists)
    }
    
    func testUpgradeRequestAcceptedWhileOnWay() {
        let scenario: EventsScenario = .UpgradeRequestAccepted
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()
        
        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.waitForUpgradeRequestPopup(withState: .accepted, timeout: 25)
        //XCTAssertEqual(testFlow.locationVCInspector.navigationSubtitleLabel.label, "SUV")
    }
    
    func testUpgradeRequestAcceptedAfterArrived() {
        let scenario: EventsScenario = .UpgradeRequestAccepted
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
    
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()
        
        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.pressCloseUpgrade()
        
        testFlow.pressArrived()
        testFlow.waitForUpgradeRequestPopup(withState: .accepted, timeout: 25)
        //XCTAssertEqual(testFlow.locationVCInspector.navigationSubtitleLabel.label, "SUV")
    }
    
    func testUpgradeRequestAcceptedAfterStartTrip() {
        let scenario: EventsScenario = .UpgradeRequestAccepted
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()
        
        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.pressCloseUpgrade()
        
        testFlow.pressArrived()
        testFlow.pressBeginTrip()
        
        testFlow.waitForUpgradeRequestPopup(withState: .accepted, timeout: 25)
        //XCTAssertEqual(testFlow.locationVCInspector.navigationSubtitleLabel.label, "SUV")
    }
    
    func testUpgradeRequestedDeclinedWhileOnWay() {
        let scenario: EventsScenario = .UpgradeRequestDeclinedByRider
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()
        
        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.waitForUpgradeRequestPopup(withState: .cancelByRider, timeout: 25)
        XCTAssertEqual(testFlow.locationVCInspector.navigationSubtitleLabel.label, "STANDARD")
    }
    
    func testUpgradeRequestedDeclinedAfterArrived() {
        let scenario: EventsScenario = .UpgradeRequestDeclinedByRider
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()
        
        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.pressCloseUpgrade()
        
        testFlow.pressArrived()
        testFlow.waitForUpgradeRequestPopup(withState: .cancelByRider, timeout: 25)
        XCTAssertEqual(testFlow.locationVCInspector.navigationSubtitleLabel.label, "STANDARD")
    }
    
    func testUpgradeRequestedDeclinedAfterStartTrip() {
        let scenario: EventsScenario = .UpgradeRequestDeclinedByRider
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()
        
        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.pressCloseUpgrade()
        
        testFlow.pressArrived()
        testFlow.pressBeginTrip()
        
        testFlow.waitForUpgradeRequestPopup(withState: .cancelByRider, timeout: 25)
        XCTAssertEqual(testFlow.locationVCInspector.navigationSubtitleLabel.label, "STANDARD")
    }
    
    func testUpgradeRequestCancelledByDriver() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()
        
        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.pressCancelUpgrade()
        
        XCTAssertEqual(testFlow.locationVCInspector.navigationSubtitleLabel.label, "STANDARD")
        
        testFlow.pressFloatingButton()
        sleep(1)
        XCTAssertFalse(testFlow.locationVCInspector.upgradeToSUVRequestedOption.exists)
        XCTAssertFalse(testFlow.locationVCInspector.upgradeToSUVOption.exists)
    }
    
    func testUpgradeRequestAcceptedIsReceivedOverAnyScreen() {
        let scenario: EventsScenario = .UpgradeRequestAccepted
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVOption)
        testFlow.pressUpgradeToSUV()
        
        testFlow.waitForUpgradeRequestPopup(withState: .requested)
        testFlow.pressCloseUpgrade()
        
        testFlow.goToEarnings()
        testFlow.waitForUpgradeRequestPopup(withState: .accepted, timeout: 25)
    }
    
    func testUpgradeRequestIsRestoreFromRide() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_UPGRADE_REQUEST_RESTORE"])
        testFlow.launch()
        
        testFlow.signInSuccess(assertInitialState: false)
        testFlow.pressFloatingButton()
        waitForElementToAppear(element: testFlow.locationVCInspector.upgradeToSUVRequestedOption)
    }
    
}
