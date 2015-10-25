//
//  User.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class User {
    var name: String?
    var thumbnail: CKAsset?
    var recordID: CKRecordID
    
    init(record: CKRecord) {
        self.recordID = record.recordID
        self.name = record["name"] as? String
        self.thumbnail = record["thumbnail"] as? CKAsset
    }
    
    var thumbnailImage: UIImage? {
        if let thumbnail = thumbnail,
            let data = NSData(contentsOfFile: thumbnail.fileURL.path!) {
                return UIImage(data: data)
        }
        return nil
    }
}