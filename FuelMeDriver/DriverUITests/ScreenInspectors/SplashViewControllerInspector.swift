//
//  SplashViewControllerInspector.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/16/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class SplashViewControllerInspector: RAUITestInspector {

}
extension SplashViewControllerInspector {
    var splashView: XCUIElement {
        return app.otherElements["splashView"]
    }
    
    var bgImage: XCUIElement {
        return app.images["splashBgImage"]
    }
    
    var logoImage: XCUIElement {
        return app.images["splashLogoImage"]
    }
    
    var signInButton: XCUIElement {
        return app.buttons["SIGN IN"]
    }
    
    //var registerButton: XCUIElement {
    //    return app.buttons["REGISTER"]
    //}
    
    var versionLabel: XCUIElement {
        return app.staticTexts["splashVersionLabel"]
    }
    
    //var waitingHUD: XCUIElement {
    //    return app.otherElements["WAITING FOR INTERNET CONNECTION..."]
    //}
}


/// Validator
extension SplashViewControllerInspector {
    func assertSplashView() {
        XCTAssertTrue(bgImage.exists)
        XCTAssertTrue(logoImage.exists)
        XCTAssertTrue(signInButton.exists)
        XCTAssertTrue(versionLabel.exists)
    }
}
