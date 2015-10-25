//
//  FileCache.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import Foundation

class FileCacheService {
    class func saveData(data: NSData, identifier: String) -> NSURL {
        let url = urlForIdentifier(identifier)
        data.writeToURL(url, atomically: false)
        return url
    }
    
    class func removeData(identifier: String) {
        try! NSFileManager.defaultManager().removeItemAtURL(urlForIdentifier(identifier))
    }
    
    private class func urlForIdentifier(identifier: String) -> NSURL {
        return destinationDirectoryPath().URLByAppendingPathComponent(identifier)
    }
    
    private class func destinationDirectoryPath() -> NSURL {
        return NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!)
    }
}