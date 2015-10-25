//
//  ThumbnailPickerService.swift
//  Goatstagram
//
//  Created by Tomasz Szulc on 24/10/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class ThumbnailPickerService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    typealias Completion = (image: UIImage?) -> Void
    
    private var picker: UIImagePickerController?
    private var completion: Completion!
    
    override init() {
        super.init()
        picker = UIImagePickerController()
        picker!.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        picker!.allowsEditing = true
        picker!.delegate = self
    }
    
    func presentInViewController(vc: UIViewController, completion: Completion) {
        vc.presentViewController(picker!, animated: true, completion: nil)
        self.completion = completion
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.completion(image: image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.completion(image: nil)
    }
}
