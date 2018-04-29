//
//  Extensions.swift
//  UtilityComponent
//
//  Created by SHUBHAM GARG on 24/03/2018.
//  Copyright © 2018 SHUBHAM GARG. All rights reserved.
//

import UIKit

/// Extends String with a shortcut method.
/// - author: SHUBHAM GARG
/// - version: 1.0
extension String {
    
    /// Only numbers
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

/// Extends Date with a shortcut method.
/// - author: SHUBHAM GARG
/// - version: 1.0
extension Date {
    
    /// Start of the day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// End of the day
    var endOfDay: Date {
        return Date(timeInterval: 24 * 60 * 60 - 1, since: self.startOfDay)
    }
}

/// Extends DateFormatter with a shortcut method.
/// - author: SHUBHAM GARG
/// - version: 1.0
extension DateFormatter {
    
    convenience init(format: String, utc: Bool = false) {
        self.init()
        self.dateFormat = format
        if utc {
            self.timeZone = TimeZone(abbreviation: "UTC")
        }
    }
}
