//
//  XCUIApplication+environment.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/16/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

extension XCUIApplication {
    
    static let XCUIAppEnvironmentAutomation = "AUTOMATION"
    static let XCUIAppBehaviorNoAuth = "ATTNoAuth"
    static let XCUIAppBehaviorNoNetwork = "ATTNoNetwork"
    static let XCUIAppArgumentNoNetworkTimeout = "--timeout"
    static let XCUIAppArgumentNoStubbing = "--noStubbing"
    static let XCUIAppArgumentCity = "--city" //no arg or 1 -> Austin, 2 -> Houston
    static let XCUIAppArgumentDelay = "--delay"
    static let XCUIAppArgumentRealAuth = "--realAuth"
    static let XCUIAppArgumentRideResources = "--rideResources"
    
    convenience init(launchArguments:[String],launchEnvironment:[String:String] = [XCUIApplication.XCUIAppEnvironmentAutomation:XCUIApplication.XCUIAppBehaviorNoAuth]) {
        self.init()
        self.launchArguments = launchArguments
        self.launchEnvironment = launchEnvironment
        
        let stubNetworkArgument = "STUB_NETWORK"
        if !self.launchArguments.contains(XCUIApplication.XCUIAppArgumentNoStubbing) {
            self.launchArguments.append(stubNetworkArgument)
        }
    }
    
}
