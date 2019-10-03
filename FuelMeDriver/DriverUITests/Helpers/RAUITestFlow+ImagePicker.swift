//
//  RAUITestFlow+ImagePicker.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 6/9/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

extension RAUITestFlow {
    func pickAnImageSuccessfully() {
        let photoSourceSheet = app.sheets["Source"]
        self.testCase.passedWhenElementAppears(element: photoSourceSheet)
        XCTAssertTrue(photoSourceSheet.staticTexts["From where do you want to take the picture?"].exists)
        XCTAssertTrue(photoSourceSheet.buttons["Camera"].exists)
        
        let btnPhotoGallery = photoSourceSheet.buttons["Choose from library"]
        btnPhotoGallery.tap()
        
        self.testCase.addUIInterruptionMonitor(withDescription: "Photo permissions dialog") { (alert) -> Bool in
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
            }
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
            }
            if alert.buttons["Dismiss"].exists {
                alert.buttons["Dismiss"].tap()
            }
            return true
        }
        
        //show photos library
        app.tables.cells.element(boundBy: 0).tap()
        app.collectionViews.element(boundBy: 0).cells.element(boundBy: 0).tap()
        
        let window = app.windows.element(boundBy: 0)
        let coordinateNormalized = window.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coordinateScreen = coordinateNormalized.withOffset(CGVector(dx: window.frame.width - 20, dy: window.frame.height - 20))
        coordinateScreen.tap()
    }
    
    func tapFromBottomWithOffset(_ offset:CGVector, referenceElement element:XCUIElement? = nil) {
        let window = app.windows.element(boundBy: 0)
        let coordinateNormalized = window.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        
        var startX = window.frame.width
        var startY = window.frame.height
        if let element = element {
            startX = element.frame.origin.x
            startY = element.frame.origin.y
        }
        
        let coordinateScreen = coordinateNormalized.withOffset(CGVector(dx: startX - offset.dx, dy: startY - offset.dy))
        coordinateScreen.tap()
    }
    
}
