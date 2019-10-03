//
//  RAUTestFlow+Session.swift
//  RideDriver
//
//  Created by Marcos Alba on 31/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

// Session behavior (Sign In, Sign Out)

extension RAUITestFlow {
    func signIn(_ user: Account) {
        let signIn = splashVCInspector.signInButton
        testCase.waitForElementToAppear(element: signIn, timeout: 15)
        signIn.tap()
        
        let emailSearchField = loginVCInspector.emailTextField
        emailSearchField.tap()
        emailSearchField.typeText(user.username)
        
        let passwordSecureTextField = loginVCInspector.passwordTextField
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(user.password)
        
        loginVCInspector.doneButton.tap()
    }
    
    func signInSuccess(assertInitialState assert:Bool = true) {
        signIn(testDriverStub)
        testCase.passedWhenElementAppears(element: locationVCInspector.navigationMenuButton)
        
        if assert {
            locationVCInspector.assertViewInState(.Initial)
        }
    }
    
    func signOut() {
        locationVCInspector.navigationMenuButton.tap()
        let tablesQuery = app.tables
        let settings = tablesQuery.staticTexts["Settings"]
        testCase.waitForElementToAppear(element: settings, timeout: 2)
        settings.tap()
        
        let signOut = tablesQuery.staticTexts["Sign out"]
        testCase.waitForElementToAppear(element: signOut)
        app.swipeUp()
        signOut.tap()
    }
}
