//
//  MainViewController.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var postButton: UIButton!
    
//    @IBOutlet var myAccountButton: UIButton!
    
    private var photos = [Photo]()
    private var user: User?
    private var assetPicker = AssetPickerService()
    
    private enum SegueIdentifier: String {
        case UserSettings
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        myAccountButton.enabled = false
        fetchUserAndUpdateView()
    }
    
    @IBAction func selectAndPostPhoto(sender: AnyObject) {
        assetPicker.presentInViewController(self) { (image) -> Void in
            guard image != nil else {
                return
            }
            
            PhotoService.postPhoto(image!, userRecordID: self.user!.recordID, completion: { (success) -> Void in
                print("photo uploaded: \(success)")
            })
        }
    }
    
    
    
    
    private func fetchUserAndUpdateView() {
        UsersService.fetchICloudUser { (user) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.user = user
                self.updateWithUser()
                PhotoService.fetchLatestPhotos({ (photos) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.photos = photos
                        self.collectionView.reloadData()
                    })
                })
            })
        }
    }
    
    private func updateWithUser() {
//        myAccountButton.enabled = user != nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.UserSettings.rawValue {
            let navigationVC = segue.destinationViewController as! UINavigationController
            let settingsVC = navigationVC.topViewController as! UserSettingsViewController
            settingsVC.user = user
        }
    }
    
    // MARK: UIcollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoCell: PhotoCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        photoCell.imageView.backgroundColor = UIColor.grayColor()
        photoCell.imageView.image = photos[indexPath.row].assetImage
        return photoCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width)
    }
}

