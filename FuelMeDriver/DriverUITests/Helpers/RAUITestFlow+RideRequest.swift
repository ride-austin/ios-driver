//
//  RAUITestFlow+RideRequest.swift
//  RideDriver
//
//  Created by Marcos Alba on 1/6/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

//Ride request

extension RAUITestFlow {
    
    func waitForRideRequest(withPriority priority: Bool = false) {
        testCase.waitForElementToAppear(element: rideRequestVCInspector.rideRequestView, timeout: 20)
        rideRequestVCInspector.assertView(withPriority: priority)
    }

    func acceptRideRequest(withComment: Bool = false){
        rideRequestVCInspector.acceptButton.tap()
        locationVCInspector.assertViewInState(.OnWay, withComment: withComment)
        testCase.waitForElementToAppear(element: locationVCInspector.driverCarMarker)
        //testCase.waitForElementToAppear(element: locationVCInspector.route, timeout: 25)
    }
    
    func goOfflineFromRideRequestScreen() {
        rideRequestVCInspector.onlineButton.tap()
        locationVCInspector.assertViewInState(.Initial)
        XCTAssertTrue(locationVCInspector.driverStatus == .Offline)
    }
    
    func declineRideRequest() {
        rideRequestVCInspector.declineButton.tap()
        locationVCInspector.assertViewInState(.Initial)
    }
}
