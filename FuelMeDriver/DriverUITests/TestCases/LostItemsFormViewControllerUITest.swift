//
//  LostItemsFormViewControllerUITest.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/7/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class LostItemsFormViewControllerUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //  https://testrail.devfactory.com//index.php?/tests/view/10205351
    func testA10205351() {
        let testFlow = RAUITestFlow(self)
        testFlow.launch()
        
        testFlow.signInSuccess()
        sleep(1)
        
        testFlow.locationVCInspector.navigationMenuButton.tap()
        
        let tablesQuery = testFlow.locationVCInspector.appTables
        tablesQuery.cells.staticTexts["Earnings"].tap()
        
        //mock data uses $10
        let scrollView = testFlow.app.scrollViews.element(boundBy: 0)
        let tenDollarDayCell = tablesQuery.cells.containing(.staticText, identifier:"$ 10.00").element(boundBy: 1)
        scrollView.scrollToElement(element: tenDollarDayCell)
        tenDollarDayCell.tap()
        
        waitForElement(element: testFlow.earningInspector.dailyEarningsNavBar)
        
        sleep(1)
        let cells = tablesQuery.cells
        let lastIndex = cells.count - 1
        let lastTripCell = cells.element(boundBy: lastIndex)
        lastTripCell.tap()
        
        let btContact = tablesQuery.cells.buttons["Contact Support"]
        testFlow.app.swipeUp()
        btContact.tap()
        
        waitForElement(element: testFlow.lostItemsFormVCInspector.navBarSelectAnIssue)
        
        //select lost item found
        tablesQuery.cells.staticTexts["Lost item found"].tap()
    }
    
    //  https://testrail.devfactory.com//index.php?/tests/view/10205350
    //  check all elements
    func testB10205350() {
        let testFlow = RAUITestFlow(self)
        let inspector = testFlow.lostItemsFormVCInspector
        waitForElement(element: inspector.navBarTellUsMore)
        XCTAssertTrue(inspector.cellBody(forType: .DriverFoundItem).exists)
        XCTAssertTrue(inspector.cellFirstLine(forType: .DriverFoundItem).exists)
        XCTAssertTrue(inspector.cellDate.exists)
        XCTAssertTrue(inspector.cellDescriptionTextView.exists)
        XCTAssertTrue(inspector.cellPhoto.exists)
        XCTAssertTrue(inspector.cellShareNumber.exists)
        XCTAssertTrue(inspector.cellDetailsTextView.exists)
        XCTAssertTrue(inspector.submitButton.exists)
    }
    
    
    //  https://testrail.devfactory.com//index.php?/tests/view/10205353
    //  check validations
    func testB10205353() {
        let testFlow = RAUITestFlow(self)
        let inspector = testFlow.lostItemsFormVCInspector
        
        inspector.submitButton.tap()
        testFlow.assertAlert(message: "Please input When did you find this item?")
        
        inspector.cellDate.tap()
        inspector.doneButton.tap()
        inspector.submitButton.tap()
        testFlow.assertAlert(message: "Please input Do you know which ride this item belongs to?")
        
        inspector.cellDescription.tap()
        inspector.cellDescriptionTextView.typeText("sample description")
        inspector.doneButton.tap()
        inspector.submitButton.tap()
        testFlow.assertAlert(message: "Please input Photo of lost item")
        
        inspector.cellPhoto.tap()
        //UIImagePickerController failing.
        //Add workaround on image selection for Automation target
        //testFlow.pickAnImageSuccessfully()
        inspector.submitButton.tap()
        testFlow.assertAlert(message: "Please input Can we share your number with the rider?")
        
        inspector.cellShareNumber.tap()
        inspector.doneButton.tap()
        inspector.submitButton.tap()
        testFlow.assertAlert(message: "Please input Share details")
        
        inspector.cellDetails.tap()
        inspector.cellDetailsTextView.typeText("sample share details")
        inspector.doneButton.tap()
        
    }
    
    //  https://testrail.devfactory.com//index.php?/tests/view/10205354
    func testB10205354() {
        let testFlow = RAUITestFlow(self)
        let inspector = testFlow.lostItemsFormVCInspector
        
        inspector.submitButton.tap()
        
        waitForElement(element: inspector.submitLostItemSuccessAlert)
        inspector.alertDismissButton.tap()
        
        waitForElement(element: inspector.navBarSelectAnIssue)
    }
    
    //  https://testrail.devfactory.com//index.php?/tests/view/10205357
    func testB10205357_skipped() {
        //
        //  email can't be verified
    }
    
    //  https://testrail.devfactory.com//index.php?/tests/view/10205358
    func testB10205358_skipped() {
        //
        //  disable internet
        //  enter fields
        //  enable internet
        //  submit to server
        //  forms will work even without internet
    }
}
