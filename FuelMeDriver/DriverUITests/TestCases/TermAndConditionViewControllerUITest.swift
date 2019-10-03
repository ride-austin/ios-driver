//
//  TermAndConditionViewControllerUITest.swift
//  RideDriver
//
//  Created by Roberto Abreu on 5/28/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class TermAndConditionViewControllerUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUIElements() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_TERM_NOT_ACCEPTED"])
        testFlow.launch()
        
        testFlow.signIn(testDriverStub)
        
        waitForElementToAppear(element: testFlow.termAndConditionInspector.newTermsAndConditionNavBar)
        
        XCTAssertTrue(testFlow.termAndConditionInspector.helpBar.visible())
        
        let scrollView = testFlow.app.scrollViews.element(boundBy: 0)
        XCTAssertTrue(scrollView.exists)
        XCTAssertTrue(testFlow.app.staticTexts["Review and approve the changes on Driver terms and conditions"].exists)
        XCTAssertTrue(testFlow.app.staticTexts["LAST UPDATE: MAY 28, 2017"].exists)
        
        let continueButton = testFlow.app.buttons["CONTINUE"]
        let checkbox = testFlow.app.buttons["checkbox off"]
        
        scrollView.scrollToElement(element: continueButton)
        XCTAssertFalse(continueButton.isEnabled)
        XCTAssertTrue(checkbox.exists && !checkbox.isSelected)
        XCTAssertTrue(testFlow.app.staticTexts["I AGREE AND ACKNOWLEDGE"].exists)
        
        checkbox.tap()
        XCTAssertTrue(checkbox.exists && checkbox.isSelected)
        XCTAssertTrue(continueButton.isEnabled)
    }
    
    func testCannotGoOnlineWithoutAcceptingTerms() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_TERM_NOT_ACCEPTED"])
        testFlow.launch()
        
        testFlow.signIn(testDriverStub)
        
        let termAndConditionNavigationBar = testFlow.termAndConditionInspector.newTermsAndConditionNavBar
        waitForElementToAppear(element: termAndConditionNavigationBar)
        
        termAndConditionNavigationBar.buttons["Back"].tap()
        
        testFlow.goOnline()
        
        let errorAlert = testFlow.app.alerts["RideAustin"]
        XCTAssertTrue(errorAlert.staticTexts["RideAustin"].exists)
        
        let messageAlertPredicate = NSPredicate(format: "label BEGINSWITH 'In order to go online you should read and accept new Driver terms and conditions'")
        XCTAssertTrue(errorAlert.staticTexts.matching(messageAlertPredicate).element.exists)
        errorAlert.buttons["Cancel"].tap()
        
        XCTAssertTrue(testFlow.locationVCInspector.driverStatus == .Offline)
        testFlow.goOnline()
        errorAlert.buttons["Read"].tap()
        XCTAssertTrue(termAndConditionNavigationBar.exists)
    }
    
    func testCanOpenNewTermsAndConditionsScreenThroughSettingsMenu() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_TERM_NOT_ACCEPTED"])
        testFlow.launch()
        
        testFlow.signIn(testDriverStub)
        
        let termAndConditionNavigationBar = testFlow.app.navigationBars["New Terms & Conditions"]
        XCTAssertTrue(termAndConditionNavigationBar.exists)
        termAndConditionNavigationBar.buttons["Back"].tap()
        
        testFlow.goToSettings()
        
        let settingsNavigationBar = testFlow.app.navigationBars["Settings"]
        XCTAssertTrue(settingsNavigationBar.exists)
        
        let settingTable = testFlow.app.tables
        let newTermCell = settingTable.cells.staticTexts["New Terms & Conditions"]
        newTermCell.tap()
        
        XCTAssertTrue(termAndConditionNavigationBar.exists)
        
        let scrollView = testFlow.app.scrollViews.element(boundBy: 0)
        let continueButton = testFlow.app.buttons["CONTINUE"]
        let checkbox = testFlow.app.buttons["checkbox off"]
        
        scrollView.scrollToElement(element: continueButton)
        checkbox.tap()
        continueButton.tap()
        
        waitForElementToAppear(element: settingsNavigationBar)
        XCTAssertFalse(newTermCell.exists)
    }
    
    func testTermsAndConditionsShowInRestartWhenNotAccepted() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_TERM_NOT_ACCEPTED"])
        testFlow.launch()
        
        testFlow.signIn(testDriverStub)
        
        let termAndConditionNavigationBar = testFlow.app.navigationBars["New Terms & Conditions"]
        XCTAssertTrue(termAndConditionNavigationBar.exists)
        termAndConditionNavigationBar.buttons["Back"].tap()
        
        testFlow.signOut()
        testFlow.signIn(testDriverStub)
        
        XCTAssertTrue(termAndConditionNavigationBar.exists)
    }
    
    func testTermsAndConditionsNotShownInRestartWhenAccepted() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_TERM_NOT_ACCEPTED"])
        testFlow.launch()
        
        testFlow.signIn(testDriverStub)
        
        let termAndConditionNavigationBar = testFlow.app.navigationBars["New Terms & Conditions"]
        XCTAssertTrue(termAndConditionNavigationBar.exists)
        
        let scrollView = testFlow.app.scrollViews.element(boundBy: 0)
        let continueButton = testFlow.app.buttons["CONTINUE"]
        let checkbox = testFlow.app.buttons["checkbox off"]
        
        scrollView.scrollToElement(element: continueButton)
        checkbox.tap()
        continueButton.tap()
        
        testFlow.signOut()
        testFlow.signIn(testDriverStub)
        
        XCTAssertFalse(termAndConditionNavigationBar.exists)
    }
    
    func testTermsAndConditionsNotShownWhenDriverAlreadyAccepted() {
        let testFlow = RAUITestFlow(self, launchArguments: [])
        testFlow.launch()
        
        testFlow.signIn(testDriverStub)
        
        let termAndConditionNavigationBar = testFlow.app.navigationBars["New Terms & Conditions"]
        XCTAssertFalse(termAndConditionNavigationBar.exists)
    }
    
    func testCanGoOnlineAfterAcceptingTerms() {
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_TERM_NOT_ACCEPTED"])
        testFlow.launch()
        
        testFlow.signIn(testDriverStub)
        
        let termAndConditionNavigationBar = testFlow.termAndConditionInspector.newTermsAndConditionNavBar
        waitForElementToAppear(element: testFlow.termAndConditionInspector.newTermsAndConditionNavBar)
        
        let scrollView = testFlow.app.scrollViews.element(boundBy: 0)
        let continueButton = testFlow.app.buttons["CONTINUE"]
        let checkbox = testFlow.app.buttons["checkbox off"]
        
        scrollView.scrollToElement(element: continueButton)
        checkbox.tap()
        continueButton.tap()
        
        testFlow.goOnline()
        XCTAssertFalse(termAndConditionNavigationBar.exists)
        XCTAssertTrue(testFlow.locationVCInspector.mapView.visible())
        XCTAssertTrue(testFlow.locationVCInspector.driverStatus == .Online)
    }
    
}
