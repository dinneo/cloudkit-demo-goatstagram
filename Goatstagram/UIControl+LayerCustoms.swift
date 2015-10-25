//
//  UIControl+LayerCustoms.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

extension CALayer {
    var borderUIColor: UIColor? {
        set {
            if (newValue != nil) { self.borderColor = newValue!.CGColor }
            else { self.borderColor = nil }
        }

        get {
            if (self.borderColor == nil) { return nil }
            else { return UIColor(CGColor: self.borderColor!) }
        }
    }
}