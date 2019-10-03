//
//  UIColor+RideAustin.swift
//  Rider
//
//  Created by Theodore Gonzalez on 4/25/18.
//  Copyright © 2018 wandercodes. All rights reserved.
//

import UIKit

@objc extension UIColor {
    static func azureBlue() -> UIColor {
        return UIColor(2,167,249)
    }
    static func barButtonGray() -> UIColor {
        return UIColor(44,50,60)
    }
    
    static func barButtonDisabled() -> UIColor {
        return UIColor(233,233,233)
    }
    
    static func barButtonEnabled() -> UIColor {
        return azureBlue()
    }
    
    static func bombayGray() -> UIColor {
        return UIColor(177,180,187)
    }
    
    static func grayBackground() -> UIColor {
        return UIColor(242,242,243)
    }
    
    static func textFieldBorder() -> UIColor {
        return UIColor(216,216,216)
    }
    
    static func placeholderColor() -> UIColor {
        return UIColor(199,199,205)
    }
    
    static func grayText() -> UIColor {
        return UIColor(60,67,80)
    }
    
    static func pickupGreen() -> UIColor {
        return UIColor(76,175,80)
    }
    
    static func destinationRed() -> UIColor {
        return UIColor(244,67,54)
    }
    
    static func femaleDriverPink() -> UIColor {
        return UIColor(249,22,135)
    }
}

extension UIColor {
    convenience init(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat, alpha: CGFloat = 1) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
}
