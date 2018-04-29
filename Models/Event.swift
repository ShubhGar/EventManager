//
//  Event.swift
//  eventManager
//
//  Created by SHUBHAM GARG on 24/03/2018.
//  Copyright © 2018 SHUBHAM GARG. All rights reserved.
//

import Foundation
import EventKit

/**
 * Event entity
 *
 * - author: SHUBHAM GARG
 * - version: 1.0
 */
struct Event {
    
    var title: String
    var dialInNumber: String?
    var accessCode: String?
    var startDate: Date
    var endDate: Date
    var attendees = [String]()
    var organizerEmail: String?
    var isAllDay = false
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - dialInNumber: the dial in number
    ///   - accessCode: the access code
    ///   - conferenceNumber: the conference number
    ///   - ciscoDevices: the cisco devices
    ///   - startDate: the start date
    ///   - endDate: the end date
    ///   - attendees: the attendees
    ///   - organizerEmail: the organizer email
    init(title: String, dialInNumber: String?, accessCode: String?, startDate: Date, endDate: Date, attendees: [String], organizerEmail: String?, isAllDay: Bool) {
        self.title = title
        self.dialInNumber = dialInNumber
        self.accessCode = accessCode
        self.startDate = startDate
        self.endDate = endDate
        self.attendees = attendees
        self.organizerEmail = organizerEmail
        self.isAllDay = isAllDay
    }
    
    /// Convert EKEvent to Event
    ///
    /// - Parameter event: the EKEvent
    /// - Returns: return Event
    static func fromEKEvent(_ event: EKEvent) -> Event {
        let title = event.title ?? ""
        let startDate = event.startDate ?? Date()
        let endDate  = event.endDate ?? Date()
        let attendees = event.attendees?.map({ $0.name ?? "Unknown" }) ?? [String]()
        let organizerEmail = event.organizer?.description.email
        
        let dialInNumber: String? = {
            if let notes = event.notes {
                for str in notes.split(separator: "\n") {
                    if let dialInNumber = String(str).dialInNumber {
                        return dialInNumber
                    }
                }
            }
            return nil
        }()
        
        let accessCode: String? = {
            if let notes = event.notes {
                for str in notes.split(separator: "\n") {
                    if let accessCode = String(str).accessCode {
                        return accessCode
                    }
                }
            }
            return nil
        }()
        
        let isAllDay = event.isAllDay
        
        return Event(title: title, dialInNumber: dialInNumber, accessCode: accessCode, startDate: startDate, endDate: endDate, attendees: attendees, organizerEmail: organizerEmail, isAllDay: isAllDay)
    }
    
    /// Is active event?
    var isActive: Bool {
        return startDate <= Date() && Date() <= endDate
    }
    
    /// Start in string based on event dates
    var startsInString: String {
        guard !isActive else {
            return "Starts Now"
        }
        
        guard Date() <= endDate else {
            return "Ended"
        }
        
        let component = Calendar.current.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: Date(), to: startDate)
        var str = "Starts in "
        if let hour = component.hour, hour > 0 {
            str += String(hour) + "h "
        }
        str += String(component.minute ?? 1) + "min"
        return str
    }
}

/// Extends String to add helper methods for Event
/// - author: SHUBHAM GARG
/// - version: 1.0
extension String {
    /// Parse Email
    var email: String? {
        if let range = self.range(of: "email = [^;]+", options: .regularExpression) {
            let str = self[range].replacingOccurrences(of: "email = ", with: "")
            return str
        } else {
            return nil
        }
    }
    
    /// Parse Dial In Number
    var dialInNumber: String? {
        if let range = self.range(of: "[\\d+][\\d\\- \\(\\)+]{8,}[\\d]", options: .regularExpression) {
            let number = String(self[range]).digits
            return number.count >= 10 && number.count <= 15 ? number : nil
        } else {
            return nil
        }
        
    }
    
    /// line includes access code
    var accessCodeExist: Bool {
        for word in Configuration.shared.accessCodeWords {
            if let _ = self.range(of: word, options: [.caseInsensitive, .regularExpression]) {
                return true
            }
        }
        return false
    }
    
    /// Parse Access Code
    var accessCode: String? {
        if self.accessCodeExist {
            if let range = self.range(of: "[\\d-]{3,}", options: .regularExpression) {
                let number = String(self[range]).digits
                return number.count > 3 && number.count <= 9 ? number : nil
            } else {
                return nil
            }
        }
        return nil
    }
}
