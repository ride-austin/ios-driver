//
//  EarningViewControllerInspector.swift
//  DriverUITests
//
//  Created by Roberto Abreu on 11/28/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class EarningViewControllerInspector: RAUITestInspector {
    
    var dailyEarningsNavBar: XCUIElement {
        if #available(iOS 11.0, *) {
            return app.navigationBars.otherElements.element(matching: NSPredicate(format: "label BEGINSWITH 'Daily Earnings'"))
        } else {
            return app.navigationBars.staticTexts["Daily Earnings"]
        }
    }
    
}
