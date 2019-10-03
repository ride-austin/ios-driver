//
//  ArrivedUITest.swift
//  RideDriver
//
//  Created by Roberto Abreu on 8/9/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class ArrivedUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRiderChangeDestination() {
        let scenario:EventsScenario = .DestinationChangedByRiderAfterDriverArrived
        let testFlow = RAUITestFlow(self, scenario: scenario)
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        
        testFlow.pressArrived()
        let currentDestination = testFlow.locationVCInspector.destinationTextField.value
        let routeValue = testFlow.locationVCInspector.route.value as! String
        waitForElementToChangeValue(testFlow.locationVCInspector.destinationTextField, originalValue: currentDestination as! String, timeout: 15)
        waitForElementToChangeValue(testFlow.locationVCInspector.route, originalValue: routeValue, timeout: 15)
    }

}
