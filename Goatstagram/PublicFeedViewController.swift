//
//  PublicFeedViewController.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CloudKit
import AudioToolbox

class PublicFeedViewController: UIViewController, UICollectionViewDataSource,
UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var postButton: UIBarButtonItem!
    
    private var photos = [Photo]()
    private var assetPicker = AssetPickerService()
    private var subscriptionID: String?
    private var goatSound: SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRecents()
        observeRecents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updatePostButton()
    }
    
    private func updatePostButton() {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (status, error) -> Void in
            if (status != .Available) {
                self.postButton.enabled = false
                let alert = UIAlertController(title: "You're not logged in", message: "Please go to iCloud settings and log in with your credentials to add photos.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Close", style: .Default, handler: nil))
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            } else {
                self.postButton.enabled = true
            }
        }
    }

    private func fetchRecents() {
        activityIndicator.startAnimating()
        PhotosService.fetchRecents(8, perPhotoCompletion: { (photo) -> Void in
                self.photos.append(photo)
                self.collectionView.reloadData()
            }) { (photos, success) -> Void in
                self.photos = photos
                self.collectionView.reloadData()
                self.playGoatSound()
                self.activityIndicator.stopAnimating()
        }
    }
    
    private func playGoatSound() {
        let path = NSBundle.mainBundle().pathForResource("goat", ofType: "wav")!
        let url = NSURL(fileURLWithPath: path)
        
        AudioServicesCreateSystemSoundID(url, &goatSound);
        AudioServicesPlaySystemSound(goatSound);
    }
    
    private func observeRecents() {
        PhotosService.subscribeForChangesInRecents { (subscriptionID) -> Void in
            self.subscriptionID = subscriptionID
            print("success subscribing recents: \(subscriptionID)")
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionNotificationReceived:", name: SubscriptionNotification, object: nil)
        }
    }
    
    func subscriptionNotificationReceived(notification: NSNotification) {
        print("received notification - new item in feed")
        if notification.userInfo!["subscriptionID"] as? String == subscriptionID {
            fetchRecents()
        }
    }
    
    // MARK: UICollectionViewDataSource
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
