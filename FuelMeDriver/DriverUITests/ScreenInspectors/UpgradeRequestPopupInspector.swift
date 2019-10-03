//
//  UpgradeRequestPopupInspector.swift
//  RideDriver
//
//  Created by Roberto Abreu on 7/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

enum UpgradeStateUI : String {
    case requested = "iconRequested"
    case accepted = "iconAccepted"
    case cancelByRider = "iconDeclined"
}

class UpgradeRequestPopupInspector : RAUITestInspector {

    var requestTitle: XCUIElement {
        return app.staticTexts["upgradeTitle"]
    }
    
    var requestMessage: XCUIElement {
        return app.staticTexts["upgradeMessage"]
    }
    
    var closeUpgradeButton : XCUIElement {
        return app.buttons["btnCloseUpgrade"]
    }
    
    var cancelUpgradeButton : XCUIElement {
        return app.buttons["btnCancelUpgrade"]
    }
    
    var iconRequestUpgrade: XCUIElement {
        return app.images["iconRequestUpgrade"]
    }
    
}

extension UpgradeRequestPopupInspector {
    
    func assertView(withState state:UpgradeStateUI) {
        switch state {
        case .requested:
            XCTAssertEqual(requestTitle.label, "Upgrade to SUV")
            XCTAssertEqual(requestMessage.label, "Waiting for Rider's Cofirmation")
            XCTAssertTrue(closeUpgradeButton.exists)
            XCTAssertTrue(cancelUpgradeButton.exists)
        case .accepted:
            XCTAssertEqual(requestTitle.label, "Rider confirmed")
            XCTAssertEqual(requestMessage.label, "Upgraded to SUV")
            XCTAssertTrue(closeUpgradeButton.exists)
            XCTAssertFalse(cancelUpgradeButton.exists)
        case .cancelByRider:
            XCTAssertEqual(requestTitle.label, "Rider denied")
            XCTAssertEqual(requestMessage.label, "Not Upgrading to SUV")
            XCTAssertTrue(closeUpgradeButton.exists)
            XCTAssertFalse(cancelUpgradeButton.exists)
        }
        XCTAssertEqual(iconRequestUpgrade.value as! String, state.rawValue)
    }
    
}
