//
//  PhotosService.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CloudKit

class PhotoService {
    class func postPhoto(image: UIImage, userRecordID: CKRecordID, completion: (success: Bool) -> Void) {
        let assetURL = FileCacheService.saveData(UIImagePNGRepresentation(image)!, identifier: userRecordID.recordName)
        let photoRecord = CKRecord(recordType: "Photos")
        photoRecord["asset"] = CKAsset(fileURL: assetURL)
        photoRecord["user"] = CKReference(recordID: userRecordID, action: CKReferenceAction.None)
        
        let database = CKContainer.defaultContainer().publicCloudDatabase
        database.saveRecord(photoRecord) { (savedRecord, error) -> Void in
            guard error == nil else {
                print(error)
                completion(success: false)
                return
            }
            
            print(savedRecord)
            completion(success: true)
        }
    }
    
    class func fetchLatestPhotos(completion: [Photo] -> Void) {
        var photos = [Photo]()
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Photos", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = 10;
        queryOperation.queryCompletionBlock = { (cursor, error) in
            if error != nil {
                print(error)
            }
            
            completion(photos)
        }
        
        queryOperation.recordFetchedBlock = { record in
            photos.append(Photo(record: record))
        }
        
        CKContainer.defaultContainer().publicCloudDatabase.addOperation(queryOperation)
    }
}