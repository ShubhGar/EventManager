//
//  ApprovalViewController.swift
//  eventManager
//
//  Created by SHUBHAM GARG on 29/02/2018.
//  Copyright © 2018 SHUBHAM GARG. All rights reserved.
//

import UIKit
import EventKit

/**
 * Approval view controller
 *
 * - author: SHUBHAM GARG
 * - version: 1.0
 */
class ApprovalViewController: UIViewController {

    /// Outlets
    @IBOutlet var permissionView: UIView?
    
    /// Event store
    let eventStore = EKEventStore()
    
    
    /// View will appear
    ///
    /// - Parameter animated: the animated flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        permissionView?.isHidden = true
    }
    
    /// View did appear
    ///
    /// - Parameter animated: the animated flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkCalendarAuthorizationStatus()
    }
    
    /// Check auhorization status
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:   // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:  // Things are in line with being able to show the calendars in the table view
            loadMain()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:    // We need to help them give us permission
            permissionView?.isHidden = false
        }
    }
    
    /// Request authoriation
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: { (accessGranted: Bool, error: Error?) in
            if accessGranted == true {
                DispatchQueue.main.async {
                    self.permissionView?.isHidden = true
                    self.loadMain()
                }
            } else {
                DispatchQueue.main.async {
                    self.permissionView?.isHidden = false
                }
            }
        })
    }
    
    /// Load main view
    private func loadMain() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true, completion: nil)
        }
    }

    /// Go to settings button handler
    ///
    /// - Parameter sender: the button
    @IBAction func goToSettingsButton(_ sender: UIButton) {
        if let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(openSettingsUrl)
        }
    }
}
