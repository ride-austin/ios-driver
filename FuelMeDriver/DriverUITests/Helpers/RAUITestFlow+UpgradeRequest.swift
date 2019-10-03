//
//  RAUITestFlow+UpgradeRequest.swift
//  RideDriver
//
//  Created by Roberto Abreu on 7/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

extension RAUITestFlow {

    func waitForUpgradeRequestPopup(withState state:UpgradeStateUI, timeout: TimeInterval = 5) {
        testCase.waitForElementToAppear(element: upgradeRequestPopupInspector.requestTitle, timeout: timeout)
        let predicate = NSPredicate(format: "value CONTAINS '\(state.rawValue)'")
        testCase.waitForElement(element: upgradeRequestPopupInspector.iconRequestUpgrade, predicate: predicate, timeout: timeout)
        upgradeRequestPopupInspector.assertView(withState: state)
    }
    
    func pressCloseUpgrade() {
        upgradeRequestPopupInspector.closeUpgradeButton.tap()
    }
    
    func pressCancelUpgrade() {
        upgradeRequestPopupInspector.cancelUpgradeButton.tap()
    }

}
