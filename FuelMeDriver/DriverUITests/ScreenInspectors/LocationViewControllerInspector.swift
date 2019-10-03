//
//  LocationViewControllerInspector.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest
import CoreLocation

class LocationViewControllerInspector: RAUITestInspector {
    
}

extension LocationViewControllerInspector {
    
    var navigationBar: XCUIElement {
        return app.navigationBars["LocationViewController"]
    }
    
    var navigationMenuButton: XCUIElement {
        return app.buttons["show menu"]
    }

    var navigationSupportButton: XCUIElement {
        return app.buttons["Support"]
    }

    var navigationContactButton: XCUIElement {
        return app.buttons["Contact"]
    }

    var driverStatusButton: XCUIElement {
        return app.buttons["driverStatusButton"]
    }
    
    var navigationTitleLabel: XCUIElement {
        return navigationBar.staticTexts["titleLabel"]
    }
    
    var navigationSubtitleLabel: XCUIElement {
        return navigationBar.staticTexts["subtitleLabel"]
    }

    var mapView: XCUIElement {
        return app.otherElements["googleMapsView"]
    }

    var googleMapsButton: XCUIElement {
        return mapView.buttons["Google Maps"]
    }
    
    var pickupMarker: XCUIElement {
        return mapView.buttons["startLocationMarker"]
    }
    
    var destinationMarker: XCUIElement {
        return mapView.buttons["endLocationMarker"]
    }
    
    var driverCarMarker: XCUIElement {
        return mapView.buttons["carMarker"]
    }
    
    var rideAddressView: XCUIElement {
        return app.otherElements["rideAddressView"]
    }
    
    var pickUpTextField: XCUIElement {
        return app.textFields["pickUpTextField"]
    }

    var destinationTextField: XCUIElement {
        return app.textFields["destinationTextField"]
    }
    
    var commentLabel: XCUIElement {
        return app.staticTexts["riderCommentText"]
    }
    
    var currentComment: String {
        return commentLabel.value as! String
    }
    
    var commentToogleButton: XCUIElement {
        return app.buttons["commentToggleButton"]
    }
    
    var navigateButton: XCUIElement {
        return app.buttons["navigateButton"]
    }
    
    var cancelTripButton: XCUIElement {
        return app.buttons["cancelTripButton"]
    }
    
    var floatingActionView: XCUIElement {
        return app.otherElements["FloatingActionButton"]
    }
    var actionView: XCUIElement {
        return app.otherElements["actionView"]
    }
    
    var actionButton: XCUIElement {
        return actionView.buttons["actionButton"]
    }
    
    var myLocationButton: XCUIElement {
        return app.otherElements["myLocationButton"]
    }
    
    var upgradeToSUVOption: XCUIElement {
        return app.otherElements["Upgrade to SUV"]
    }
    
    var upgradeToSUVRequestedOption: XCUIElement {
        return app.otherElements["Upgrade Requested"]
    }

    var appTables: XCUIElementQuery {
        return app.tables
    }
    
    var forgetToStartRideAlertTitle: XCUIElement {
        return app.staticTexts["Did you forget to start the ride?"]
    }
    
    var dontShowAgainOnThisTripButton : XCUIElement {
        return app.buttons["Don't show again (on this trip)"]
    }
    
    var startTripAlert: XCUIElement {
        return app.staticTexts["Are you sure you want to start the trip?"]
    }
    
    var endTripAlert: XCUIElement {
        return app.staticTexts["Are you sure you want to end the trip?"]
    }

    var yesButton: XCUIElement {
        return app.buttons["Yes"]
    }
    
    var ratingView: XCUIElement {
        return app.otherElements["ratingFareView"]
    }
    
    var driverEarningsLabel: XCUIElement {
        return app.staticTexts["Driver Earnings"]
    }
    
    var  fareLabel: XCUIElement {
        return app.staticTexts["fareLabel"]
    }
    
    var  driverEarnings: Float {
        var fareString = fareLabel.label
        fareString = fareString.replacingOccurrences(of: "$ ", with: "")
        return Float(fareString)!
    }
    
    var starRatingView: XCUIElement {
        return app.otherElements["starRatingView"]
    }
    
    var ratingSubmitButon: XCUIElement {
        return app.buttons["rateSubmitButton"]
    }

    var activeDrivers: XCUIElementQuery {
        let carsPredicate = NSPredicate(format: "label beginsWith[cd] 'DRIVER'")
        return app.buttons.matching(carsPredicate)
    }
    
    var riderMarker: XCUIElement {
        return mapView.buttons["riderLocationMarker"]
    }
    
    var route: XCUIElement {
        return mapView.otherElements["routePath"]
    }
    
    var currentCarCoordinate: CLLocationCoordinate2D {
        guard let driverMarkerCoordinateJSON = driverCarMarker.value as? String,
              let jsonData = driverMarkerCoordinateJSON.data(using: .utf8) else {
            return kCLLocationCoordinate2DInvalid
        }
        
        do {
            let coordDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Double]
            guard let lat = coordDict?["lat"], let lon = coordDict?["lon"] else {
                return kCLLocationCoordinate2DInvalid
            }
            
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } catch{
            print("Json serialization error: \(error)")
            return kCLLocationCoordinate2DInvalid
        }
    }
    
    var routeValue: (start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        guard let routeJSON = route.value as? String, let jsonData = routeJSON.data(using: .utf8) else {
            return (kCLLocationCoordinate2DInvalid,kCLLocationCoordinate2DInvalid)
        }
        
        do {
            let routeDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Dictionary<String,Double>]
            guard let startDict = routeDict?["start"] else {
                return (kCLLocationCoordinate2DInvalid,kCLLocationCoordinate2DInvalid)
            }
            guard let startLat = startDict["lat"] else {
                return (kCLLocationCoordinate2DInvalid,kCLLocationCoordinate2DInvalid)
            }
            guard let startLon = startDict["lon"] else {
                return (kCLLocationCoordinate2DInvalid,kCLLocationCoordinate2DInvalid)
            }
            let startCoord = CLLocationCoordinate2D(latitude: startLat, longitude: startLon)

            guard let endDict = routeDict?["end"] else {
                return (startCoord,kCLLocationCoordinate2DInvalid)
            }
            guard let endLat = endDict["lat"] else {
                return (startCoord,kCLLocationCoordinate2DInvalid)
            }
            guard let endLon = endDict["lon"] else {
                return (startCoord,kCLLocationCoordinate2DInvalid)
            }
            let endCoord = CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
            
            return (startCoord, endCoord)
            
        } catch{
            print("Json serialization error: \(error)")
            return (kCLLocationCoordinate2DInvalid,kCLLocationCoordinate2DInvalid)
        }
    }
    
    var currentRiderCoordinate: CLLocationCoordinate2D {
        guard let riderMarkerCoordinateJSON = riderMarker.value as? String,
            let jsonData = riderMarkerCoordinateJSON.data(using: .utf8) else {
            return kCLLocationCoordinate2DInvalid
        }
        
        do {
            let coordDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Double]
            guard let lat = coordDict?["lat"], let lon = coordDict?["lon"] else {
                return kCLLocationCoordinate2DInvalid
            }
           
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } catch{
            print("Json serialization error: \(error)")
            return kCLLocationCoordinate2DInvalid
        }
    }
    
}

extension LocationViewControllerInspector {
    
    enum DriverStatus: String {
        case Online = "ONLINE"
        case Offline = "OFFLINE"
    }
    
    enum LocationVCViewState {
        case Initial
        case OnWay
        case Arrived
        case Riding
    }
    
    enum ActionStatus: String {
        case Arrived = "ARRIVED"
        case BeginTrip = "BEGIN TRIP"
        case EndTrip = "END TRIP"
    }
    
    var driverStatus: DriverStatus {
        let statusText = driverStatusButton.label;
        return DriverStatus(rawValue: statusText)!
    }
    
    var actionStatus: ActionStatus {
        let statusText = actionButton.label
        return ActionStatus(rawValue: statusText)!
    }

    func assertNavigation(withTitle title:String,andSubTitle subTitle:String) {
        XCTAssertEqual(navigationTitleLabel.label, title)
        XCTAssertEqual(navigationSubtitleLabel.label, subTitle)
    }
    
    func assertViewInState(_ state: LocationVCViewState, withComment: Bool = false) {
        switch state {
        case .Initial:
            assertViewInInitialState()
        case .OnWay:
            assertViewInOnWayState(withComment: withComment)
        case .Arrived:
            assertViewInArrivedState(withComment: withComment)
        case .Riding:
            assertViewInRidingState()
        }
    }
    
    func assertRatingView() {
        XCTAssert(fareLabel.exists)
        XCTAssert(starRatingView.exists)
        XCTAssert(ratingSubmitButon.exists)
    }

    private func assertViewInInitialState() {
        XCTAssertTrue(mapView.exists)
        XCTAssertTrue(navigationBar.exists)
        XCTAssertTrue(navigationMenuButton.exists)
        XCTAssertTrue(navigationSupportButton.exists)
        XCTAssertTrue(driverStatusButton.exists)
        XCTAssertTrue(driverCarMarker.exists)
        XCTAssertTrue(googleMapsButton.exists)
        XCTAssertTrue(floatingActionView.exists)
    }
   
    ///TO DO: check navigation title with rider name and pins
    private func assertViewInOnWayState(withComment: Bool = false) {
        XCTAssertTrue(mapView.exists)
        XCTAssertTrue(navigationBar.exists)
        XCTAssertTrue(navigationTitleLabel.exists)
        XCTAssertTrue(navigationSubtitleLabel.exists)
        XCTAssertTrue(navigationMenuButton.exists)
        XCTAssertTrue(navigationContactButton.exists)
        XCTAssertFalse(driverStatusButton.exists)
        //XCTAssertTrue(driverCarMarker.exists)
        XCTAssertTrue(googleMapsButton.exists)
        XCTAssertTrue(floatingActionView.exists)
        XCTAssertTrue(actionStatus == .Arrived)
        XCTAssertTrue(pickUpTextField.exists)
        XCTAssertFalse(destinationTextField.exists)
        if withComment {
            XCTAssertTrue(commentLabel.exists)
        } else {
            XCTAssertFalse(commentLabel.exists)
        }
        XCTAssertTrue(navigateButton.exists)
        XCTAssertTrue(cancelTripButton.exists)
    }

    ///TO DO: check navigation title with rider name and pins
    private func assertViewInArrivedState(withComment: Bool = false) {
        XCTAssertTrue(mapView.exists)
        XCTAssertTrue(navigationBar.exists)
        XCTAssertTrue(navigationMenuButton.exists)
        XCTAssertTrue(navigationContactButton.exists)
        XCTAssertFalse(driverStatusButton.exists)
        //XCTAssertTrue(driverCarMarker.exists)
        XCTAssertTrue(googleMapsButton.exists)
        XCTAssertTrue(floatingActionView.exists)
        XCTAssertTrue(actionStatus == .BeginTrip)
        XCTAssertTrue(pickUpTextField.exists)
        XCTAssertTrue(destinationTextField.exists)
        if withComment {
            XCTAssertTrue(commentLabel.exists)
        } else {
            XCTAssertFalse(commentLabel.exists)
        }
        XCTAssertTrue(navigateButton.exists)
        XCTAssertTrue(cancelTripButton.exists)
    }

    ///TO DO: check navigation title with rider name and pins
    private func assertViewInRidingState() {
        XCTAssertTrue(mapView.exists)
        XCTAssertTrue(navigationBar.exists)
        XCTAssertTrue(navigationMenuButton.exists)
        XCTAssertTrue(navigationContactButton.exists)
        XCTAssertFalse(driverStatusButton.exists)
        //XCTAssertTrue(driverCarMarker.exists)
        XCTAssertTrue(googleMapsButton.exists)
        XCTAssertTrue(floatingActionView.exists)
        XCTAssertTrue(actionStatus == .EndTrip)
        XCTAssertTrue(pickUpTextField.exists)
        XCTAssertTrue(destinationTextField.exists)
        XCTAssertFalse(commentLabel.exists)
        XCTAssertTrue(navigateButton.exists)
        XCTAssertFalse(cancelTripButton.exists)
    }

}
