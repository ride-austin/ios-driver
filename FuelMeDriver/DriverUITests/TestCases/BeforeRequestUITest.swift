//
//  BeforeRequestUITest.swift
//  RideDriver
//
//  Created by Marcos Alba on 29/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest
class BeforeRequestUITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // 1.  Before Request: Can go online. https://issue-tracker.devfactory.com/browse/RA-11808
    // http://testrail.devfactory.com/index.php?/cases/view/753415

    func test1_CanGoOnline() {
        let testFlow = RAUITestFlow(self)
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        sleep(1)
        XCTAssertTrue(testFlow.locationVCInspector.driverStatus == .Online)
    }
    
    // 2.  Before Request: Can go offline. https://issue-tracker.devfactory.com/browse/RA-11684
    // http://testrail.devfactory.com/index.php?/cases/view/753416
    
    func test2_CanGoOffline() {
        let testFlow = RAUITestFlow(self)
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        sleep(1)
        XCTAssertTrue(testFlow.locationVCInspector.driverStatus == .Online)
        testFlow.goOffline()
        sleep(1)
        XCTAssertTrue(testFlow.locationVCInspector.driverStatus == .Offline)
    }

    // 3. Before Request: Map Verification - driver's car position, locate me button. https://issue-tracker.devfactory.com/browse/RA-10554
    // http://testrail.devfactory.com/index.php?/cases/view/753638
    
    func test3_MapVerification1Elements() {
        let testFlow = RAUITestFlow(self)
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        sleep(1)
        XCTAssertTrue(testFlow.locationVCInspector.driverStatus == .Online)
        XCTAssertTrue(testFlow.locationVCInspector.mapView.exists)
        XCTAssertTrue(testFlow.locationVCInspector.driverCarMarker.exists)
        testFlow.moveMap()
        testFlow.moveMap()
        XCTAssertFalse(testFlow.locationVCInspector.driverCarMarker.exists)
        testFlow.pressMyLocationButton()
        sleep(1)
        XCTAssertTrue(testFlow.locationVCInspector.driverCarMarker.exists)
    }
    
    // 4. Before Request: Map Verification - zoom in, zoom out and move. https://issue-tracker.devfactory.com/browse/RA-11686
    // http://testrail.devfactory.com/index.php?/cases/view/753871
    
    func test4_MapVerification2Gestures() {
        let testFlow = RAUITestFlow(self)
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        sleep(1)
        XCTAssertTrue(testFlow.locationVCInspector.driverStatus == .Online)
        XCTAssertTrue(testFlow.locationVCInspector.mapView.exists)
        XCTAssertTrue(testFlow.locationVCInspector.driverCarMarker.exists)
        testFlow.zoomMapIn()
        XCTAssertTrue(testFlow.locationVCInspector.driverCarMarker.exists)
        testFlow.zoomMapOut()
        XCTAssertTrue(testFlow.locationVCInspector.driverCarMarker.exists)
        testFlow.moveMap(.Right)
        testFlow.moveMap(.Left)
        waitForElementToAppear(element: testFlow.locationVCInspector.driverCarMarker, timeout: 25)
    }
   
    // 5. Before Request: Map Verification - other driver's cars. https://issue-tracker.devfactory.com/browse/RA-11687
    // http://testrail.devfactory.com/index.php?/cases/view/1033800
    
    func test5_MapVerification3OtherDrivers() {
        let testFlow = RAUITestFlow(self)
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        sleep(1)
        XCTAssertTrue(testFlow.locationVCInspector.driverStatus == .Online)
        XCTAssertTrue(testFlow.locationVCInspector.mapView.exists)
        XCTAssertTrue(testFlow.locationVCInspector.driverCarMarker.exists)
        testFlow.zoomMapOut()
        sleep(1)
        XCTAssertTrue(testFlow.locationVCInspector.driverCarMarker.exists)
        XCTAssertTrue(testFlow.locationVCInspector.activeDrivers.count > 0)
    }
}

