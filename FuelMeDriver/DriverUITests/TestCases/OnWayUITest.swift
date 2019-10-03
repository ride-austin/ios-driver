//
//  OnWayUITest.swift
//  RideDriver
//
//  Created by Marcos Alba on 29/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest
class OnWayUITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRiderChangeDestination() {
        let scenario:EventsScenario = .DestinationChangedByRiderOnWay
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        waitForElementToAppear(element: testFlow.locationVCInspector.route)
        let routeValue = testFlow.locationVCInspector.route.value as! String
        sleep(15)
        XCTAssertEqual(routeValue, testFlow.locationVCInspector.route.value as! String)
    }
    
    func testDriverCanCancelRideWhileOnWay() {
        let scenario:EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        waitForElementToAppear(element: testFlow.locationVCInspector.cancelTripButton)
        testFlow.pressCancelTrip()
        waitForElementToAppear(element: testFlow.locationVCInspector.driverStatusButton, timeout: 25)
        testFlow.locationVCInspector.assertViewInState(.Initial)
    }
    
    func testAdminCancelRide() {
        let scenario:EventsScenario = .AdminCanceledRide
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
    
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        waitForElementToAppear(element: testFlow.locationVCInspector.driverStatusButton, timeout: 15)
        testFlow.locationVCInspector.assertViewInState(.Initial)
    }
    
    func testAutoArriveToPickup() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue, "MAP_DEFAULT_LOCATION_MANAGER"])
        testFlow.launch()
    
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        waitForElementToAppear(element: testFlow.locationVCInspector.destinationTextField)
        testFlow.locationVCInspector.assertViewInState(.Arrived)
    }
    
    func testDriverCanPressArrived() {
        let scenario: EventsScenario = .IncomingRideRequest
        let testFlow = RAUITestFlow(self, launchArguments: [scenario.rawValue])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.locationVCInspector.actionButton.tap()
        waitForElementToAppear(element: testFlow.locationVCInspector.destinationTextField)
        testFlow.locationVCInspector.assertViewInState(.Arrived)
    }
    
}

