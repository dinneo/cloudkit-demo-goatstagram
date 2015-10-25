//
//  UserSettingsViewController.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CloudKit

class UserSettingsViewController: UIViewController {

    @IBOutlet private var thumbnailButton: UIButton!
    @IBOutlet private var nameTextField: UITextField!
    
    private var thumbnailPicker = ThumbnailPickerService()
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateWithUser()
    }
    
    private func updateWithUser() {
        nameTextField.text = user.name
        thumbnailButton.setBackgroundImage(user.thumbnailImage, forState: .Normal)
    }
    
    @IBAction func thumbnailPressed(sender: AnyObject) {
        thumbnailPicker.presentInViewController(self) { (image) -> Void in
            self.thumbnailButton.setBackgroundImage(image, forState: .Normal)
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        /// Get name
        user.name = nameTextField.text
        
        /// Get thumbnail
        if let thumbnailImage = thumbnailButton.backgroundImageForState(.Normal) {
            let thumbnailURL = FileCacheService.saveData(UIImagePNGRepresentation(thumbnailImage)!, identifier: user.recordID.recordName)
            user.thumbnail = CKAsset(fileURL: thumbnailURL)
        } else {
            user.thumbnail = nil
        }
        
        /// Save user and update UI
        UsersService.saveUser(user) { (success) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (success == true) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    print("Cannot save user. Try again.")
                }
            })
        }
    }
}
