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
    private var userRecordID: CKRecordID?
    private var operationQueue = NSOperationQueue()
    
    private enum SegueIdentifier: String {
        case ShowPhoto
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    private func configureView() {
        AccountService.accountStatus { available in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.postButton.enabled = available
                
                /// Show alert with error
                if available == true {
                    /// Create operation to fetch CKRecordID of a user
                    let fetchingUserRecordOperation = NSBlockOperation() {
                        print("fetching user record operation")
                        let semaphore = dispatch_semaphore_create(0)
                        AccountService.fetchUserRecordID { userRecordID in
                            self.userRecordID = userRecordID
                            dispatch_semaphore_signal(semaphore)
                        }
                        
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                    }
                    
                    /// Create operation of fetching recent posts
                    let fetchingRecentsOperation = NSBlockOperation() {
                        print("fetching recents operation")
                        let semaphore = dispatch_semaphore_create(0)
                        PhotosService.fetchRecents(8, perPhotoCompletion: { (photo) -> Void in
                                self.photos.append(photo)
                                self.collectionView.reloadData()
                            }) { (photos, success) -> Void in
                                self.photos = photos
                                self.collectionView.reloadData()
                                self.playGoatSound()
                                self.activityIndicator.stopAnimating()
                                dispatch_semaphore_signal(semaphore)
                        }

                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                    }
                    
                    let observingChangesOperation = NSBlockOperation() {
                        print("observing changes operation")
                        let semaphore = dispatch_semaphore_create(0)
                        PhotosService.subscribeForChangesInRecents { (subscriptionID) -> Void in
                            self.subscriptionID = subscriptionID
                            print("success subscribing recents: \(subscriptionID)")
                            NSNotificationCenter.defaultCenter().addObserver(self, selector: "subscriptionNotificationReceived:", name: SubscriptionNotification, object: nil)
                            dispatch_semaphore_signal(semaphore)
                        }
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                    }
                    
                    /// configure queue
                    self.operationQueue = NSOperationQueue()
                    self.operationQueue.name = "PublicFeed.configure"
                    self.operationQueue.maxConcurrentOperationCount = 2
                    
                    /// add operations with dependencies
                    observingChangesOperation.addDependency(fetchingRecentsOperation)
                    fetchingRecentsOperation.addDependency(fetchingUserRecordOperation)
                    self.operationQueue.addOperations([fetchingUserRecordOperation, fetchingRecentsOperation, observingChangesOperation], waitUntilFinished: false)
                    
                } else {
                    self.postButton.enabled = false
                    let alert = UIAlertController(title: "You're not logged in", message: "Please go to iCloud settings and log in with your credentials to add photos.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    private func playGoatSound() {
        let path = NSBundle.mainBundle().pathForResource("goat", ofType: "wav")!
        let url = NSURL(fileURLWithPath: path)
        
        AudioServicesCreateSystemSoundID(url, &goatSound);
        AudioServicesPlaySystemSound(goatSound);
    }
    
    func subscriptionNotificationReceived(notification: NSNotification) {
        print("received notification - new item in feed")
        if notification.userInfo!["subscriptionID"] as? String == subscriptionID {
            fetchRecents(1)
        }
    }
    
    func fetchRecents(number: Int) {
        PhotosService.fetchRecents(number, perPhotoCompletion: { (photo) -> Void in
            // do nothing
            }, completion: { (photos, success) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.insertPhoto(photos.first!)
                    })
                }
        })
    }
    
    func insertPhoto(photo: Photo) {
        self.photos.insert(photo, atIndex: 0)
        self.collectionView.reloadData()
        self.playGoatSound()
    }
    
    @IBAction func selectAndPostPhoto() {
        assetPicker.presentInViewController(self) { image in
            if image != nil {
                PhotosService.postPhoto(image!, userRecordID: self.userRecordID!, completion: { (savedRecord) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if savedRecord != nil {
                            self.insertPhoto(Photo(record: savedRecord!))
                        }

                        var alert: UIAlertController!
                        if savedRecord != nil {
                            alert = UIAlertController(title: "Success", message: "Photo posted", preferredStyle: .Alert)
                        } else {
                            alert = UIAlertController(title: "Failure", message: "Photo not posted. Try again.", preferredStyle: .Alert)
                        }
                        
                        alert.addAction(UIAlertAction(title: "Close", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                })
            }
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
