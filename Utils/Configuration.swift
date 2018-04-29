//
//  Configuration.swift
//  eventManager
//
//  Created by SHUBHAM GARG on 29/03/2018.
//  Copyright © 2018 SHUBHAM GARG. All rights reserved.
//

import Foundation

/**
 * Configuration
 *
 * - author: SHUBHAM GARG
 * - version: 1.0
 */
class Configuration {
    
    /// Singleton object
    static let shared = Configuration()
    
    /// Info list
    var infos = [Info]()
    
    /// Email subject
    var emailSubject = ""
    
    /// Email body
    var emailBody = ""
    
    /// Words for parsing access code
    var accessCodeWords = [String]()
    
    /// Initialize
    private init() {
        if let path = Bundle.main.path(forResource: "Configuration", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String:AnyObject] {
                if let array = dict["Infos"] as? [[String:String]] {
                    infos.removeAll()
                    for item in array {
                        let title = item["Title"] ?? ""
                        let filename = item["Filename"] ?? ""
                        infos.append(Info(title: title, filename: filename))
                    }
                }
                emailSubject = dict["emailSubject"] as? String ?? emailSubject
                emailBody = dict["emailBody"] as? String ?? emailBody
                accessCodeWords = dict["accessCodeWords"] as? [String] ?? accessCodeWords
            }
        }
    }
}
