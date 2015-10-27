//
//  UserService.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CloudKit

class AccountService {
    class func accountStatus(completion: (available: Bool) -> Void) {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (status, error) -> Void in
            print("account status = \(status.rawValue)")
            guard error == nil else {
                print("UserService err: \(error)")
                completion(available: false)
                return
            }
            completion(available: true)
        }
    }
    
    class func fetchUserRecordID(completion: CKRecordID? -> Void) {
        let database = CKContainer.defaultContainer()
        database.fetchUserRecordIDWithCompletionHandler { (fetchedRecordID, error) -> Void in
            guard error == nil else {
                print("AccountService error: \(error)")
                completion(nil)
                return
            }
            completion(fetchedRecordID)
        }
    }
}
