//
//  LoginViewControllerInspector.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class LoginViewControllerInspector: RAUITestInspector {
        
}
extension LoginViewControllerInspector {
    
    var signInNavigationBar: XCUIElement {
        return app.navigationBars["Sign In"]
    }
    
    var emailTextField: XCUIElement {
        return app.textFields["Email"]
    }
    
    var passwordTextField: XCUIElement {
        return app.secureTextFields["Password"]
    }
    
    var doneButton: XCUIElement {
        return app.navigationBars.buttons["DONE"]
    }
    
    var signInFailedAlert: XCUIElement {
        return app.alerts["SIGN IN FAILED"]
    }
    
    var facebookLoginButton: XCUIElement {
        let btnIdentifier = "CONTINUE WITH FACEBOOK"
        let btn = app.buttons[btnIdentifier]
        return btn.exists ? btn : app.scrollViews.otherElements.buttons[btnIdentifier]
    }
    
    var facebookWVEmailTextField: XCUIElement {
        return app.webViews.textFields["Email or Phone"]
    }
    
    var facebookWVPasswordTextField: XCUIElement {
        return app.webViews.secureTextFields["Facebook Password"]
    }
    
    var facebookWVLoginButton: XCUIElement{
        return app.webViews.buttons["Log In"]
    }
    
    var facebookWVOKButton: XCUIElement{
        return app.webViews.buttons["OK"]
    }
    
}

/// Validator
extension LoginViewControllerInspector {
    
}
