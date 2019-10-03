//
//  OnTripUITest.swift
//  RideDriver
//
//  Created by Roberto Abreu on 8/15/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class OnTripUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testTripStartedWithoutDestination() {
        let scenario:EventsScenario = .IncomingRideRequestWithoutDestination
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressArrived()
        testFlow.pressBeginTrip()
        
        //Apple Bug: Empty textfield is returning placeholder value. Xcode9 iOS11
        //https://forums.developer.apple.com/thread/86653
        XCTAssertEqual(testFlow.locationVCInspector.destinationTextField.value as! String , "Enter destination")
        
        XCTAssertFalse(testFlow.locationVCInspector.route.exists)
        XCTAssertFalse(testFlow.locationVCInspector.destinationMarker.exists)
    }
    
    func testAdminCancelRide() {
        let scenario:EventsScenario = .AdminCanceledRide
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressArrived()
        testFlow.pressBeginTrip()
        
        waitForElementToAppear(element: testFlow.locationVCInspector.driverStatusButton, timeout: 15)
        testFlow.locationVCInspector.assertViewInState(.Initial)
    }
    
    func testAfterRiderChangeDestinationRouteAndAddressUpdated() {
        let scenario:EventsScenario = .DestinationChangedByRiderWhileOnTrip
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressArrived()
        testFlow.pressBeginTrip()
        
        //Apple Bug: Empty textfield is returning placeholder value. Xcode9 iOS11
        //https://forums.developer.apple.com/thread/86653
        waitForElementToChangeValue(testFlow.locationVCInspector.destinationTextField, originalValue: "Enter destination", timeout: 25)

        XCTAssertTrue(testFlow.locationVCInspector.destinationMarker.exists)
        XCTAssertTrue(testFlow.locationVCInspector.route.exists)
        XCTAssertEqual(testFlow.locationVCInspector.destinationTextField.value as! String, "North Shoal Creek")
    }
    
}
