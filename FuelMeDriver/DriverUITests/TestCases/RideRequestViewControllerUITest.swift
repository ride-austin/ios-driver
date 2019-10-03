//
//  RideRequestViewControllerUITest.swift
//  RideDriver
//
//  Created by Roberto Abreu on 6/21/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class RideRequestViewControllerUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCanDeclineRideRequest() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.declineRideRequest()
    }
    
    func testCanGoOfflineFromRideRequestScreen() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.goOfflineFromRideRequestScreen()
    }
    
    func testPriorityMultiplierForRideRequest() {
        let scenario: EventsScenario = .IncomingRideRequestPriority
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.declineRideRequest()
        
        testFlow.waitForRideRequest(withPriority: true)
        XCTAssertTrue(testFlow.rideRequestVCInspector.priorityLabel.label == "3.50X")
    }
    
    func testAcceptButtonColorByRequestType() {
        let scenario: EventsScenario = .IncomingRideRequestPerType
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.rideRequestVCInspector.assertAcceptButton(withType: .normal)
        testFlow.declineRideRequest()
        
        testFlow.waitForRideRequest(withPriority: true)
        testFlow.rideRequestVCInspector.assertAcceptButton(withType: .priority)
        testFlow.declineRideRequest()
        
        testFlow.waitForRideRequest(withPriority: true)
        testFlow.rideRequestVCInspector.assertAcceptButton(withType: .womanOnly)
        testFlow.declineRideRequest()
        
        testFlow.waitForRideRequest()
        testFlow.rideRequestVCInspector.assertAcceptButton(withType: .womanOnly)
    }
    
    func testCurrentScreenIsReplaceWithRideRequestScreen() {
        let scenario: EventsScenario = .IncomingRideRequestPerScreen
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        
        testFlow.waitForRideRequest()
        testFlow.declineRideRequest()
        
        testFlow.goToSettings()
        testFlow.waitForRideRequest()
        testFlow.declineRideRequest()
        
        testFlow.goToEarnings()
        testFlow.waitForRideRequest()
        testFlow.declineRideRequest()
        
        testFlow.goToRideRequestType()
        testFlow.waitForRideRequest()
        testFlow.declineRideRequest()
        
        testFlow.goToUpdateDocuments()
        testFlow.waitForRideRequest()
        testFlow.declineRideRequest()
    }
    
    func testDriverAndPickupMarkerExits() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        
        XCTAssertTrue(testFlow.rideRequestVCInspector.pickupMarker.exists)
        XCTAssertTrue(testFlow.rideRequestVCInspector.driverMarker.exists)
        XCTAssertEqual(testFlow.rideRequestVCInspector.primaryAddressLabel.value as! String, "11624 Jollyville Road")
    }
    
    func testRideRequestScreenIsHideAfterTenSeconds() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { 
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertFalse(testFlow.rideRequestVCInspector.rideRequestView.exists)
    }
    
}
