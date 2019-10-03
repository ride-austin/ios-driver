//
//  XCUIElement+Util.swift
//  RideDriver
//
//  Created by Roberto Abreu on 5/30/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

extension XCUIElement {
    
    func tapClear() {
        let btClear = self.buttons["Clear text"]
        if btClear.exists {
            btClear.tap()
        }
    }
    
    func clearAndTypeText(_ text: String) {
        let btClear = self.buttons["Clear text"]
        if btClear.exists {
            btClear.tap()
        }
        self.typeText(text)
    }
    
    func clearAndEnterText(text: String) -> Void {
        self.forceTap()
        self.deleteText()
        self.typeText(text)
    }
    
    func deleteText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKeyDelete
        }
        self.typeText(deleteString)
    }
    
    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            coordinate.tap()
        }
    }

    func scrollToElement(element: XCUIElement) {
        while !element.visible() {
            swipeUp()
        }
    }
    
    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
    
}
