//
//  RAUITestFlow+Map.swift
//  RideDriver
//
//  Created by Marcos Alba on 31/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest
import CoreLocation

enum MapDirection {
    case Up
    case Right
    case Down
    case Left
}

// Map

extension RAUITestFlow {
    
    func goOnline() {
        if locationVCInspector.driverStatus != .Online {
            locationVCInspector.driverStatusButton.tap()
        }
    }
    
    func goOffline() {
        if locationVCInspector.driverStatus != .Offline {
            locationVCInspector.driverStatusButton.tap()
        }
    }
    
    func pressBackButton() {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
    func goToSettings() {
        locationVCInspector.navigationMenuButton.tap()
        locationVCInspector.appTables.staticTexts["Settings"].tap()
    }
    
    func goToEarnings() {
        locationVCInspector.navigationMenuButton.tap()
        locationVCInspector.appTables.staticTexts["Earnings"].tap()
    }
    
    func goToRideRequestType() {
        locationVCInspector.navigationMenuButton.tap()
        locationVCInspector.appTables.staticTexts["Ride Request Type"].tap()
    }
    
    func goToUpdateDocuments() {
        locationVCInspector.navigationMenuButton.tap()
        locationVCInspector.appTables.staticTexts["Settings"].tap()
        app.tables.cells.staticTexts["Update Documents"].tap()
    }
    
    func waitForActionView(_ timeout: TimeInterval = 5) {
        testCase.waitForElementToAppear(element: locationVCInspector.actionView)
        XCTAssertTrue(locationVCInspector.actionButton.exists)
    }
    
    func pressArrived(withComment: Bool = false) {
        if locationVCInspector.actionStatus == .Arrived {
            locationVCInspector.actionButton.tap()

            let forgetStartRideAlert = locationVCInspector.forgetToStartRideAlertTitle
            if forgetStartRideAlert.exists {
                let dontShowAgainButton = locationVCInspector.dontShowAgainOnThisTripButton
                if dontShowAgainButton.exists {
                    dontShowAgainButton.tap()
                }
            }
            
            locationVCInspector.assertViewInState(.Arrived, withComment: withComment)

        }
    }
    
    func pressBeginTrip() {
        if locationVCInspector.actionStatus == .BeginTrip {
            locationVCInspector.actionButton.tap()
        }
        
        if locationVCInspector.startTripAlert.exists {
            locationVCInspector.yesButton.tap()
        }
        
        locationVCInspector.assertViewInState(.Riding)
    }

    func pressEndTrip() {
        if locationVCInspector.actionStatus == .EndTrip {
            locationVCInspector.actionButton.tap()
        }
        
        if locationVCInspector.endTripAlert.exists {
            locationVCInspector.yesButton.tap()
        }

        waitForRatingView()        
    }
    
    func pressCancelTrip() {
        locationVCInspector.cancelTripButton.tap()
        app.alerts.buttons["YES"].tap()
    }
    
    func pressFloatingButton() {
        self.tapFromBottomWithOffset(CGVector(dx: 25, dy: 65))
    }
    
    func pressMyLocationButton() {
        self.tapFromBottomWithOffset(CGVector(dx: 25, dy: 25))
        testCase.waitForElementToAppear(element: locationVCInspector.myLocationButton)
        locationVCInspector.myLocationButton.tap()
    }
    
    func pressUpgradeToSUV() {
        let upgradeToSUVOption = locationVCInspector.upgradeToSUVOption
        if !upgradeToSUVOption.exists {
            pressFloatingButton()
            testCase.waitForElementToAppear(element: upgradeToSUVOption)
        }
        upgradeToSUVOption.forceTap()
    }
    
    func waitForRatingView(_ timeout: TimeInterval = 15) {
        testCase.waitForElementToAppear(element: locationVCInspector.driverEarningsLabel, timeout: timeout)
        locationVCInspector.assertRatingView()
    }
    
    func rate(_ stars: Int = 3) {
        //Not implemented choosing number of stars
        locationVCInspector.starRatingView.tap()
    }
    
    func submitRating(_ stars: Int = 3) {
        if !locationVCInspector.ratingSubmitButon.isHittable {
            rate()
        }
        locationVCInspector.ratingSubmitButon.tap()
        locationVCInspector.assertViewInState(.Initial)
    }
    
    func toggleCommentView() {
        if locationVCInspector.commentToogleButton.exists {
            locationVCInspector.commentToogleButton.tap()
        }
    }
    
    func moveMap(_ direction: MapDirection = .Left) {
        switch direction {
        case .Up:
            locationVCInspector.mapView.swipeUp()
        case .Right:
            locationVCInspector.mapView.swipeRight()
        case .Down:
            locationVCInspector.mapView.swipeDown()
        case .Left:
            locationVCInspector.mapView.swipeLeft()
        }
    }
    
    func zoomMapIn() {
        locationVCInspector.mapView.pinch(withScale: 2, velocity: 2)
    }

    func zoomMapOut() {
        locationVCInspector.mapView.pinch(withScale: 0.5, velocity: -1)
    }
    
    func currentCarCoordinateIs(_ coord: CLLocationCoordinate2D) -> Bool {
        let currentCarCoordinate = locationVCInspector.currentCarCoordinate
        
        return (currentCarCoordinate.latitude != kCLLocationCoordinate2DInvalid.latitude && currentCarCoordinate.longitude != kCLLocationCoordinate2DInvalid.longitude) && (currentCarCoordinate.latitude == coord.latitude && currentCarCoordinate.longitude == coord.longitude)
    }
    
    func currentRouteHasMovedFrom(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> Bool {
        let (currentStart, currentEnd) = locationVCInspector.routeValue
        
        let startAreEquals = currentStart.latitude == start.latitude && currentStart.longitude == start.longitude
        let endAreEquals = currentEnd.latitude == end.latitude && currentEnd.longitude == end.longitude
        
        return !startAreEquals || !endAreEquals
    }
}
