//
//  Info.swift
//  eventManager
//
//  Created by SHUBHAM GARG on 29/03/2018.
//  Copyright © 2018 SHUBHAM GARG. All rights reserved.
//

import Foundation

/**
 * Info entity
 *
 * - author: SHUBHAM GARG
 * - version: 1.0
 */
struct Info {
    var title: String
    var filename: String
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - filename: the filename
    init(title: String, filename: String) {
        self.title = title
        self.filename = filename
    }
}
