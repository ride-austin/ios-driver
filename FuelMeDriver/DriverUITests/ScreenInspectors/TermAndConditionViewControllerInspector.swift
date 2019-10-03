//
//  TermAndConditionViewControllerInspector.swift
//  DriverUITests
//
//  Created by Roberto Abreu on 11/30/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class TermAndConditionViewControllerInspector: RAUITestInspector {
    
    var newTermsAndConditionNavBar: XCUIElement {
        return app.navigationBars["New Terms & Conditions"]
    }
    
    var helpBar: XCUIElement {
        return app.otherElements.matching(identifier: "helpBar").element
    }
    
}
