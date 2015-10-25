//
//  Photo.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit
import CloudKit

class Photo {
    var recordID: CKRecordID
    var user: CKReference
    var asset: CKAsset
    
    init(record: CKRecord) {
        self.recordID = record.recordID
        self.user = record["user"] as! CKReference
        self.asset = record["asset"] as! CKAsset
    }
    
    var assetImage: UIImage? {
        if let data = NSData(contentsOfFile: asset.fileURL.path!) {
            return UIImage(data: data)
        }
        
        return nil
    }
}