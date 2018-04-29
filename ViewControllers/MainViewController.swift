//
//  MainViewController.swift
//  eventManager
//
//  Created by SHUBHAM GARG on 29/02/2018.
//  Copyright © 2018 SHUBHAM GARG. All rights reserved.
//

import UIKit
import EventKit
import CoreData

/**
 * Main view controller
 *
 * - author: SHUBHAM GARG
 * - version: 1.0
 */
class MainViewController: UIViewController {

    /// Outlets
    @IBOutlet var tableView: UITableView?
    @IBOutlet weak var noEventFoundLabel: UILabel!
    
    /// Calendar events
    var events = [Event]()
    
    /// Reload table timer
    var timer: Timer?
    
    /// Index for option opend row
    var openedRow = -1
    
    /// Refresh control for table view
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshHandler(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Events", attributes: [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
            NSAttributedStringKey.foregroundColor: UIColor(hex: 0x999999)
            ])
        return refreshControl
    }()
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.addSubview(refreshControl)
    }
    
    /// View will disappear
    ///
    /// - Parameter animated: the animated flag
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    /// View will appear
    ///
    /// - Parameter animated: the animated flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Today - " + DateFormatter(format: "MMM d, yyyy").string(from: Date())
        loadEvents()
    }
    
    /// Refresh handler
    ///
    /// - Parameter sender: the refresh control
    @IBAction func refreshHandler(_ sender: UIRefreshControl) {
        openedRow = -1
        self.loadEvents({
            self.refreshControl.endRefreshing()
        })
    }
    

    /// Load events from calendar
    ///
    /// - Parameter callback: success callback
    func loadEvents(_ callback: (()->())? = nil) {
        timer?.invalidate()
        
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: EKEntityType.event)
        
        let predicate = eventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().endOfDay, calendars: calendars)
        events.removeAll()
        for ekEvent in eventStore.events(matching: predicate) {
            let event = Event.fromEKEvent(ekEvent)


            events.append(event)
        }
        callback?()
        if events.count <= 0{
            let alert = UIAlertController(title: "No Event Found Today.", message: "")
            present(alert, animated: true, completion: nil)
            noEventFoundLabel.isHidden = false
            tableView?.reloadData()
            return
        }
        noEventFoundLabel.isHidden = true
        tableView?.reloadData()
        
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(scheduledReload(_:)), userInfo: nil, repeats: true)

        
    }
    
    /// Reload table to update time information - not reload data
    ///
    /// - Parameter sender: the timer
    @IBAction func scheduledReload(_ sender: Timer) {
        tableView?.reloadData()
    }
    
    
    func gotoAppleCalendar(date: NSDate) {
        let interval = date.timeIntervalSinceReferenceDate
        let url = NSURL(string: "calshow:\(interval)")!
        UIApplication.shared.openURL(url as URL)
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// Number of rows
    ///
    /// - Parameters:
    ///   - tableView: the table
    ///   - section: the section index
    /// - Returns: number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    /// Cell for index path
    ///
    /// - Parameters:
    ///   - tableView: the table view
    ///   - indexPath: the index path
    /// - Returns: Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as? EventCell else {
            return UITableViewCell()
        }
        cell.configure(events[indexPath.row], isOpen: indexPath.row == openedRow)
        
        cell.openOption = {
            self.openedRow = indexPath.row
            tableView.reloadData()
        }
        cell.closeOption = {
            self.openedRow = -1
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.gotoAppleCalendar(date: self.events[indexPath.row].startDate as NSDate)
    }
}

/**
 * Event cell
 *
 * - author: SHUBHAM GARG
 * - version: 1.0
 */
class EventCell: UITableViewCell {
    
    /// IBOutlets
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var descLabel: UILabel?
    @IBOutlet var warningButton: UIButton?
    @IBOutlet var callButton: UIButton?
    @IBOutlet var leadingConstraint: NSLayoutConstraint?
    @IBOutlet var mainView: UIView?
    
    @IBOutlet var dialInImageView: UIImageView?
    @IBOutlet var passcodeImageView: UIImageView?
    @IBOutlet var notifyImageView: UIImageView?
    
    var event: Event?
    
    /// Open option for a cell
    var openOption: (()->())?
    
    var closeOption: (()->())?
    
    /// Configure cell
    ///
    /// - Parameter event: the event
    func configure(_ event: Event, isOpen: Bool) {
        titleLabel?.text = event.title
        descLabel?.text = {
            let count = event.attendees.count
            if count == 0 {
                return "No attendees"
            } else if count == 1 {
                return event.attendees[0]
            } else if count <= 3 {
                return Array(event.attendees.prefix(count-1)).joined(separator: ", ") + " & " + event.attendees[count-1]
            } else if count == 4 {
                return Array(event.attendees.prefix(3)).joined(separator: ", ") + " & 1 other"
            } else {
                return Array(event.attendees.prefix(2)).joined(separator: ", ") + " & \(count-2) others"
            }
        }()
        timeLabel?.text = {
            let timeString = event.isAllDay ? "All Day" : DateFormatter(format: "h:mm a").string(from: event.startDate)
             return timeString + " - " + event.startsInString
        }()
        
        leadingConstraint?.constant = 0
        
        self.event = event
        
        if event.isActive && event.dialInNumber != nil && event.accessCode != nil {
            callButton?.isHidden = false
            warningButton?.isHidden = true
        } else {
            callButton?.isHidden = true
            warningButton?.isHidden = !event.isActive
            
            dialInImageView?.image = event.dialInNumber == nil ? #imageLiteral(resourceName: "x") : #imageLiteral(resourceName: "check")
            passcodeImageView?.image = event.accessCode == nil ? #imageLiteral(resourceName: "x") : #imageLiteral(resourceName: "check")
            notifyImageView?.image = event.organizerEmail == nil ? #imageLiteral(resourceName: "x") : #imageLiteral(resourceName: "message")
            
            [UISwipeGestureRecognizerDirection.left, .right].forEach({
                let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
                swipe.direction = $0
                self.addGestureRecognizer(swipe)
            })
            
            if isOpen {
                openMoreInfo()
            }
        }
    }
    
    /// Swipe gesture handler
    ///
    /// - Parameter sender: the gesture
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        guard let leadingConstraint = leadingConstraint, callButton?.isHidden == true else {
            return
        }
        
        if sender.direction == .left, leadingConstraint.constant == 0 {
            openOption?()
        } else if sender.direction == .right, leadingConstraint.constant < 0 {
            closeMoreInfo()
            closeOption?()
        }
    }
    
    /// Call button handler
    ///
    /// - Parameter sender: the button
    @IBAction func callButton(_ sender: UIButton) {
        
        if let dialInNumber = event?.dialInNumber,
            let accessCode = event?.accessCode,
            let url = URL(string: "tel://" + dialInNumber + "," + accessCode + "#") {
            UIApplication.shared.openURL(url)
        }
    }
    
    /// Notify button handler
    ///
    /// - Parameter sender: the button
    @IBAction func notifyButton(_ sender: UIButton) {
        guard let event = event else { return }
        
        let subject =  String(format: Configuration.shared.emailSubject, event.title)
        let body = Configuration.shared.emailBody
        let encodedParams = "?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let email = event.organizerEmail, let url = URL(string: "mailto:" + email + encodedParams) {
            UIApplication.shared.openURL(url)
        }
    }
    
    /// Warning button handler
    ///
    /// - Parameter sender: the button
    @IBAction func warningButton(_ sender: UIButton) {
        if leadingConstraint?.constant != 0 {
            closeMoreInfo()
            closeOption?()
        } else {
            openOption?()
        }
    }
    
    /// Open more info with animation
    private func openMoreInfo() {
        leadingConstraint?.constant = -258
        setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    /// Close more info with animation
    private func closeMoreInfo() {
        leadingConstraint?.constant = 0
        setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
