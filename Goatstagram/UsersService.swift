//
//  UserService.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CloudKit

class UsersService {
    class func fetchICloudUser(completion: (user: User?) -> Void) {
        let database = CKContainer.defaultContainer()
        database.fetchUserRecordIDWithCompletionHandler { (userRecordID, error) -> Void in
            guard error == nil else {
                print(error)
                completion(user: nil)
                return
            }
            
            database.publicCloudDatabase.fetchRecordWithID(userRecordID!, completionHandler: { (userRecord, error) -> Void in
                guard error == nil else {
                    print(error)
                    completion(user: nil)
                    return;
                }
                
                print(userRecord!)
                completion(user: User(record: userRecord!))
            })
        }
    }
    
    class func saveUser(user: User, completion: (success: Bool) -> Void) {
        let database = CKContainer.defaultContainer()
        database.publicCloudDatabase.fetchRecordWithID(user.recordID) { (fetchedRecord, error) -> Void in
            guard error == nil else {
                print(error)
                completion(success: false)
                return
            }
            
            fetchedRecord!["name"] = user.name
            fetchedRecord!["thumbnail"] = user.thumbnail
            
            database.publicCloudDatabase.saveRecord(fetchedRecord!) { (savedRecord, error) -> Void in
                guard error == nil else {
                    print(error)
                    completion(success: false)
                    return
                }
                
                print("User saved: \(savedRecord!)")
                completion(success: true)
            }

        }
    }
}