//
//  RideRequestViewControllerInspector.swift
//  RideDriver
//
//  Created by Marcos Alba on 1/6/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

enum RideRequestType {
    case normal
    case womanOnly
    case priority
    
    func acceptRepresentation()->(title: String,color: String) {
        switch self {
        case .normal:
            return (title:"Accept", color:"0.00392157 0.737255 0 1")
        case .womanOnly:
            return (title:"Accept \nFEMALE DRIVER", color:"0.976471 0.14902 0.552941 1")
        case .priority:
            return (title:"Accept", color:"0.00784314 0.654902 0.976471 1")
        }
    }
    
    func countDownBackgroundStringRepresentation()->String {
        switch self {
        case .normal:
            return "0.00784314 0.627451 0.00392157 1"
        case .womanOnly:
            return "0.913725 0.0117647 0.45098 1"
        case .priority:
            return "0.0235294 0.568627 0.839216 1"
        }
    }
    
}

class RideRequestViewControllerInspector: RAUITestInspector {
    
}

extension RideRequestViewControllerInspector {

    var rideRequestView: XCUIElement {
        return app.otherElements["RideRequestView"]
    }
    
    var declineButton: XCUIElement {
        return app.buttons["Decline"]
    }

    var etaLabel: XCUIElement {
        return app.staticTexts["lblETA"]
    }

    var primaryAddressLabel: XCUIElement {
        return app.staticTexts["lblPrimaryAddress"]
    }

    var riderUsernameLabel: XCUIElement {
        return app.staticTexts["lblRiderUsername"]
    }

    var riderImage: XCUIElement {
        return app.images["imgRider"]
    }

    var carTypeLabel: XCUIElement {
        return app.staticTexts["lblCarType"]
    }

    var acceptButton: XCUIElement {
        return app.buttons["btnAccept"]
    }
    
    var onlineButton: XCUIElement {
        return app.navigationBars["RideRequestScreen"].buttons["driverStatusButton"]
    }
    
    var priorityLabel: XCUIElement {
        return app.staticTexts["lblPriority"]
    }
    
    var countdownLabel: XCUIElement {
        return app.staticTexts["lblCountDown"]
    }
    
    var driverMarker: XCUIElement {
        return app.buttons["carRideRequest"]
    }
    
    var pickupMarker: XCUIElement {
        return app.buttons["pickupRideRequest"]
    }
    
}

extension RideRequestViewControllerInspector {
    
    func assertView(withPriority: Bool = false){
        XCTAssertTrue(rideRequestView.exists)
        XCTAssertTrue(declineButton.exists)
        XCTAssertTrue(etaLabel.exists)
        XCTAssertTrue(primaryAddressLabel.exists)
        XCTAssertTrue(riderUsernameLabel.exists)
        XCTAssertTrue(riderImage.exists)
        XCTAssertTrue(carTypeLabel.exists)
        XCTAssertTrue(acceptButton.exists)
        if withPriority {
            XCTAssertTrue(priorityLabel.exists)
        }
    }
    
    func assertAcceptButton(withType type:RideRequestType) {
        let (title,backgroundColor) = type.acceptRepresentation()
        let countDonwBackground:String = type.countDownBackgroundStringRepresentation()
        
        XCTAssertTrue((acceptButton.value as! String).contains(title))
        XCTAssertTrue((acceptButton.value as! String).contains(backgroundColor))
        XCTAssertTrue((countdownLabel.value as! String).contains(countDonwBackground))
    }
    
}
