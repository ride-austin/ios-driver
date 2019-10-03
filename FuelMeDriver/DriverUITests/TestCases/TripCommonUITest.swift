//
//  TripCommonUITest.swift
//  RideDriver
//
//  Created by Roberto Abreu on 8/9/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class TripCommonUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUIElementsByState() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        //On Way
        testFlow.locationVCInspector.assertViewInState(.OnWay)
        testFlow.locationVCInspector.assertNavigation(withTitle: "Kitos", andSubTitle: "STANDARD")
        waitForElementToAppear(element: testFlow.locationVCInspector.route, timeout: 25)
        
        //Arrived
        testFlow.pressArrived()
        testFlow.locationVCInspector.assertViewInState(.Arrived)
        testFlow.locationVCInspector.assertNavigation(withTitle: "Kitos", andSubTitle: "STANDARD")
        waitForElementToAppear(element: testFlow.locationVCInspector.route, timeout: 25)
        
        //On Trip
        testFlow.pressBeginTrip()
        testFlow.locationVCInspector.assertViewInState(.Riding)
        testFlow.locationVCInspector.assertNavigation(withTitle: "Kitos", andSubTitle: "STANDARD")
        waitForElementToAppear(element: testFlow.locationVCInspector.route, timeout: 25)
    }
    
    func testMapVerificationGestures() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        func interactWithMap() {
            testFlow.zoomMapIn()
            testFlow.zoomMapOut()
            testFlow.moveMap(.Right)
            testFlow.moveMap(.Left)
            testFlow.moveMap(.Up)
            testFlow.moveMap(.Down)
        }
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        //On Way State
        interactWithMap()
        
        //Arrived State
        testFlow.pressArrived()
        interactWithMap()
        
        //OnTrip State
        testFlow.pressBeginTrip()
        interactWithMap()
    }
    
    func testDriverIsNotAbleToLogout() {
        let scenario:EventsScenario = .IncomingRideRequestPriority
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        func assertSignOut() {
            testFlow.signOut()
            testFlow.pressBackButton()
        }
        
        //On Way State
        assertSignOut()
        
        //Arrived State
        testFlow.pressArrived()
        assertSignOut()
        
        //On Trip State
        testFlow.pressBeginTrip()
        assertSignOut()
    }
    
    func testDriverNotReceiveNewRideRequestWhileOnTrip() {
        let scenario:EventsScenario = .IncomingRideRequestPerType
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        func assertRideRequestScreen(){
            let expectation = XCTestExpectation()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
            XCTAssertFalse(testFlow.rideRequestVCInspector.rideRequestView.exists)
        }
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        //On Way State
        assertRideRequestScreen()
        
        //Arrived State
        testFlow.pressArrived()
        assertRideRequestScreen()
        
        //On Trip State
        testFlow.pressBeginTrip()
        assertRideRequestScreen()
    }
    
    func testRiderLiveLocationUpdate() {
        let scenario:EventsScenario = .RiderLiveLocationUpdate
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        //On Way State
        let riderMarker = testFlow.locationVCInspector.riderMarker
        waitForElementToAppear(element: riderMarker)
        var originalValue = riderMarker.value as! String
        waitForElementToAppear(element: riderMarker)
        waitForElementToChangeValue(riderMarker, originalValue: originalValue)
        originalValue = riderMarker.value as! String
        
        //Arrived State
        testFlow.pressArrived()
        waitForElementToChangeValue(riderMarker, originalValue: originalValue)
        originalValue = riderMarker.value as! String
        waitForElementToChangeValue(riderMarker, originalValue: originalValue)
        
        //OnTrip State
        testFlow.pressBeginTrip()
        sleep(5)
        XCTAssertFalse(riderMarker.exists)
    }
    
    func testRiderLiveLocationExpire() {
        let scenario:EventsScenario = .RiderLiveLocationExpire
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        //On Way State
        let riderMarker = testFlow.locationVCInspector.riderMarker
        waitForElementToAppear(element: riderMarker)
        waitForElementToDisappear(riderMarker, timeout: 6)
        
        //Arrived State
        waitForElementToAppear(element: riderMarker)
        waitForElementToDisappear(riderMarker, timeout: 6)
    }
    
    func testDriverCompleteTrip() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue, "MAP_DEFAULT_LOCATION_MANAGER"])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        waitForElementToAppear(element: testFlow.locationVCInspector.destinationTextField)
        testFlow.locationVCInspector.assertViewInState(.Arrived)
        
        //Begin Trip
        testFlow.pressBeginTrip()
        testFlow.locationVCInspector.assertViewInState(.Riding)
        
        //TODO: On Trip
    }
    
}
