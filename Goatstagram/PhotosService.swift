//
//  PhotosService.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CloudKit

class PhotosService {
    class func postPhoto(image: UIImage, userRecordID: CKRecordID, completion: (savedRecord: CKRecord?) -> Void) {
        let assetURL = FileCacheService.saveData(UIImagePNGRepresentation(image)!, identifier: userRecordID.recordName)
        let photoRecord = CKRecord(recordType: "Photos")
        photoRecord["asset"] = CKAsset(fileURL: assetURL)
        photoRecord["user"] = CKReference(recordID: userRecordID, action: CKReferenceAction.None)
        
        let database = CKContainer.defaultContainer().publicCloudDatabase
        database.saveRecord(photoRecord) { (savedRecord, error) -> Void in
            guard error == nil else {
                print("PhotoService error: \(error)")
                completion(savedRecord: nil)
                return
            }
            
            print(savedRecord)
            completion(savedRecord: savedRecord)
        }
    }
    
    class func fetchRecents(number: Int, perPhotoCompletion: Photo -> Void, completion: (photos: [Photo], success: Bool) -> Void) {
        print("fetching recents...")
        var photos = [Photo]()
        
        let query = CKQuery(recordType: "Photos", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = number;
        
        queryOperation.queryCompletionBlock = { (cursor, error) in
            print("fetching recents completed.")
            if error != nil {
                print("PhotoService error: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(photos: photos, success: error == nil)
            })
        }
        
        queryOperation.recordFetchedBlock = { record in
            print("photo downloaded")
            let photo = Photo(record: record)
            photos.append(photo)
            
            dispatch_async(dispatch_get_main_queue(), {
                perPhotoCompletion(photo)
            })
        }
        
        CKContainer.defaultContainer().publicCloudDatabase.addOperation(queryOperation)
    }
    
    class func subscribeForChangesInRecents(completion: (subscriptionID: String?) -> Void) {
        CKContainer.defaultContainer().publicCloudDatabase.fetchAllSubscriptionsWithCompletionHandler { (subscriptions, error) -> Void in
            guard error == nil else {
                print("PhotoService error: \(error)")
                completion(subscriptionID: nil)
                return
            }
            
            /// Check if subscription exists
            for subscription in subscriptions! {
                if subscription.recordType == "Photos" && subscription.subscriptionOptions == [.FiresOnRecordCreation] {
                    print("subscription exists")
                    completion(subscriptionID: subscription.subscriptionID)
                    return
                }
            }
            
            /// Create new subscription
            let subscription = CKSubscription(recordType: "Photos", predicate: NSPredicate(value: true), options: [.FiresOnRecordCreation])
            
            CKContainer.defaultContainer().publicCloudDatabase.saveSubscription(subscription) { (savedSubscription, error) -> Void in
                if error != nil {
                    print("PhotoService error: \(error)")
                }
                
                print("subscribed for new photos")
                completion(subscriptionID: savedSubscription?.subscriptionID)
            }
        }
    }
}