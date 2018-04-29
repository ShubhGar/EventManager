//
//  UIExtensions.swift
//  UtilityComponent
//
//  Created by SHUBHAM GARG on 28/03/2018.
//  Copyright © 2018 SHUBHAM GARG. All rights reserved.
//

import UIKit

/// Extends UIColor with a shortcut method.
/// - author: SHUBHAM GARG
/// - version: 1.0
extension UIColor {
    
    /**
     Get UIColor from hex (Int), e.g. 0xFF0000 -> red color
     
     - parameter hex: the hex int
     - parameter alpha: the alpha color
     - returns: the UIColor instance
     */
    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: alpha)
    }
}

/// Extends UIAlertController with a shortcut method.
/// - author: SHUBHAM GARG
/// - version: 1.0
extension UIAlertController {
    convenience init(title: String, message: String) {
        self.init(title: title, message: message, preferredStyle: .alert)
        self.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
}
