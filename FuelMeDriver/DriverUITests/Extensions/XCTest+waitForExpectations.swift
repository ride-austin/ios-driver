//
//  XCTest+waitForExpectations.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/16/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate,
                    evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }
    
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let notExistsPredicate = NSPredicate(format: "exists == false")
        
        expectation(for: notExistsPredicate,
                    evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to wait until disappeared \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
        
    }
    
    func waitForElementToHasValue(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "value != nil")
        
        expectation(for: existsPredicate,
                    evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to wait for a value on \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }
    
    func waitForElementToChangeValue(_ element: XCUIElement, originalValue: String, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let differentPredicate = NSPredicate(format: "value != %@",originalValue)
        
        expectation(for: differentPredicate,
                    evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to wait for value changing on \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }
    
    func passedWhenElementAppears(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate,
                    evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }
    
    func waitForElement(element: XCUIElement, predicate: NSPredicate = NSPredicate(format: "value != nil"), timeout: TimeInterval = 5, file: String = #file, line: UInt = #line) {
        expectation(for: predicate,
                    evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout) { (error) in
            if (error != nil) {
                let message = "Element \(element) failed to satisfy predicate \(predicate) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }
}
