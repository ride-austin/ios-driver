//
//  LostItemsFormViewControllerInspector.swift
//  Ride
//
//  Created by Theodore Gonzalez on 6/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

enum LIFormType {
    case RiderContactDriver
    case RiderLostItem
    case DriverFoundItem
}
class LostItemsFormViewControllerInspector: RAUITestInspector {
    
}
extension LostItemsFormViewControllerInspector {
    var tablesQuery: XCUIElementQuery {
        return app.tables
    }

    var navBarTellUsMore: XCUIElement {
        if #available(iOS 11.0, *) {
            return app.navigationBars.otherElements.element(matching: NSPredicate(format: "label BEGINSWITH 'Tell us more'"))
        } else {
            return app.navigationBars.staticTexts["Tell us more"]
        }
    }
    
    var navBarSelectAnIssue: XCUIElement {
        if #available(iOS 11.0, *) {
            return app.navigationBars.otherElements.element(matching: NSPredicate(format: "label BEGINSWITH 'Select an Issue'"))
        } else {
            return app.navigationBars.staticTexts["Select an Issue"]
        }
    }
    
    //  Contact my driver
    var contactDriverSuccessAlert: XCUIElement {
        let successMessage = "We are now connecting you to your driver. If your driver doesn't pick up, leave a detailed voicemail describing your item and the best way to contact you."
        return app.alerts.staticTexts[successMessage]
    }
    
    //  I couldn't reach my driver about a lost item
    var itemDescriptionCell: XCUIElement {
        return tablesQuery.cells.staticTexts["Item description"]
    }
    var itemDescriptionTextView: XCUIElement {
        return tablesQuery.cells.containing(.staticText, identifier: "Item description").children(matching: .textView).element(boundBy: 0)
    }
    var shareDetailsCell: XCUIElement {
        return tablesQuery.cells.staticTexts["Share details"]
    }
    var shareDetailsTextView: XCUIElement {
        return tablesQuery.cells.containing(.staticText, identifier: "Share details").children(matching: .textView).element(boundBy: 0)
    }
    
    var phoneCell: XCUIElement {
        return tablesQuery.cells.staticTexts["Enter the best phone number to reach you"]
    }
    
    var submitLostItemSuccessAlert: XCUIElement {
        let successMessage = "Thank you. We’ve received your message and we will reach out to you as soon as possible."
        return app.alerts.staticTexts[successMessage]
    }
    
    //found items
    var cellDate: XCUIElement {
        return tablesQuery.cells.staticTexts["When did you find this item?"]
    }
    var cellDescription: XCUIElement {
        return tablesQuery.cells.staticTexts["Do you know which ride this item belongs to?"]
    }
    
    var cellDescriptionTextView: XCUIElement {
        return tablesQuery.cells.containing(.staticText, identifier:"Do you know which ride this item belongs to?").children(matching: .textView).element(boundBy: 1)
    }
    
    var cellPhoto: XCUIElement {
        return tablesQuery.cells.staticTexts["Photo of lost item"]
    }
    
    var cellShareNumber: XCUIElement {
        return tablesQuery.cells.staticTexts["Can we share your number with the rider?"]
    }
    
    var cellDetails: XCUIElement {
        return tablesQuery.cells.staticTexts["Share details"]
    }
    
    var cellDetailsTextView: XCUIElement {
        return tablesQuery.cells.containing(.staticText, identifier:"Share details").children(matching: .textView).element(boundBy: 1)
    }
    
    //common
    var phoneTextField: XCUIElement {
        return tablesQuery.cells.textFields["phoneTextField"]
    }
    
    var submitButton: XCUIElement {
        return app.tables.buttons["Submit"]
    }
    
    var alertDismissButton: XCUIElement {
        return app.alerts.buttons["Dismiss"]
    }
    
    var nextButton: XCUIElement {
        return app.toolbars.children(matching: .button).element(boundBy: 1)
    }
    var doneButton: XCUIElement {
        return app.toolbars.buttons["Done"]
    }
    
    func cellFirstLine(forType: LIFormType) -> XCUIElement {
        var firstLine = ""
        switch forType {
        case .RiderContactDriver:
            firstLine = "I couldn't reach my driver about a lost item"
        case .RiderLostItem:
            firstLine = "I lost an item"
        case .DriverFoundItem:
            firstLine = "I found an item"
        }
        return tablesQuery.cells.staticTexts[firstLine]
    }
    func cellBody(forType: LIFormType) -> XCUIElement {
        var formBody = ""
        switch forType {
        case .RiderContactDriver:
            formBody = "The best way to retrieve an item you may have left in a vehicle is to call the driver. Here's how:\n\n1. Scroll down and enter the phone number you would like to be contacted at. Tap submit.\n\nIf you lost your personal phone, enter a friend's phone number instead.\n\n2. We'll call the number you enter to connect you directly with your driver's mobile number.\n\nIf your driver picks up and confirms that your item has been found, coordinate a mutually convenient time and place to meet for its return to you.\n\nPlease be considerate that your driver's personal schedule will be affected by taking time out to return your item to you.\n\nDrivers are independent contractors. Neither RideAustin nor drivers are responsible for the items left in a vehicle after a trip ends. We're here to help, but cannot guarantee that a driver has your item or can immediately deliver it to you."
        case .RiderLostItem:
            formBody = "Calling your driver to connect is the best way to retrieve an item you may have left in a vehicle. If you have not tried contacting your driver directly, head back and select \"Contact my driver about a lost item\".\n\nIf more than 24 hours have passed since your trip ended and you're still unable to connect with your driver, we'll step in to help. Please share some details below.\n\nDrivers are independent contractors. Neither RideAustin nor drivers are responsible for the items left in a vehicle after a trip ends. We're here to help, but cannot guarantee that a driver has your item or can immediately deliver it to you."
        case .DriverFoundItem:
            formBody = "If you notice an item left behind, please let us know by sharing details and a photo here.\n\nWe'll help you connect with the rider so that the two of you can arrange a mutually convenient time and place for a return. In the next 48 hours, the rider may reach out to you directly to recover the lost item.\n\nIn the meantime, please keep the item safe.\n\nIn the future, it's helpful to remind riders to take all their belongings as they exit your vehicle."
        }
        return tablesQuery.cells.staticTexts[formBody]
    }
}
//  Validator
extension LostItemsFormViewControllerInspector {
    
}
