//
//  ViewController.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var myAccountButton: UIButton!
    
    private var user: User?
    
    private enum SegueIdentifier: String {
        case UserSettings
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        myAccountButton.enabled = false
        fetchUserAndUpdateView()
    }
    
    private func fetchUserAndUpdateView() {
        UsersService.fetchICloudUser { (user) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.user = user
                self.updateWithUser()
            })
        }
    }
    
    private func updateWithUser() {
        myAccountButton.enabled = user != nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.UserSettings.rawValue {
            let navigationVC = segue.destinationViewController as! UINavigationController
            let settingsVC = navigationVC.topViewController as! UserSettingsViewController
            settingsVC.user = user
        }
    }
}

