//
//  RAUITestFlow.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/16/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class RAUITestFlow {
    let testCase: XCTestCase
    let app: XCUIApplication
    let splashVCInspector: SplashViewControllerInspector
    let loginVCInspector: LoginViewControllerInspector
    let locationVCInspector: LocationViewControllerInspector
    let rideRequestVCInspector: RideRequestViewControllerInspector
    let lostItemsFormVCInspector: LostItemsFormViewControllerInspector
    let upgradeRequestPopupInspector: UpgradeRequestPopupInspector
    let earningInspector: EarningViewControllerInspector
    let termAndConditionInspector: TermAndConditionViewControllerInspector
    
    convenience init(_ testCase: XCTestCase) {
        self.init(testCase, launchArguments: [])
    }
    
    convenience init(_ testCase: XCTestCase, launchArguments: [String]) {
        self.init(testCase, launchArguments: launchArguments, launchEnvironment: [XCUIApplication.XCUIAppEnvironmentAutomation:XCUIApplication.XCUIAppBehaviorNoAuth])
    }
    
    convenience init(_ testCase: XCTestCase, scenario: EventsScenario, launchArguments: [String] = [], launchEnvironment: [String:String] = [XCUIApplication.XCUIAppEnvironmentAutomation:XCUIApplication.XCUIAppBehaviorNoAuth]){
        var args = [String]()
        args.append(contentsOf: launchArguments)
        args.append(scenario.rawValue)
        
        self.init(testCase, launchArguments: args, launchEnvironment: launchEnvironment)
    }

    init(_ testCase: XCTestCase, launchArguments: [String], launchEnvironment:[String:String]) {
        self.testCase = testCase
        self.app = XCUIApplication(launchArguments: launchArguments, launchEnvironment: launchEnvironment)
        self.splashVCInspector   = SplashViewControllerInspector(app)
        self.loginVCInspector    = LoginViewControllerInspector(app)
        self.locationVCInspector = LocationViewControllerInspector(app)
        self.rideRequestVCInspector = RideRequestViewControllerInspector(app)
        self.lostItemsFormVCInspector = LostItemsFormViewControllerInspector(app)
        self.upgradeRequestPopupInspector = UpgradeRequestPopupInspector(app)
        self.earningInspector = EarningViewControllerInspector(app)
        self.termAndConditionInspector = TermAndConditionViewControllerInspector(app)
    }
    
    func launch() {
        app.launch()
    }
}

extension RAUITestFlow {
    func assertAlert(message: String, timeout:TimeInterval = 5) {
        let validationAlert = self.app.alerts.staticTexts[message]
        self.testCase.passedWhenElementAppears(element: validationAlert, timeout: timeout)
    }
}
