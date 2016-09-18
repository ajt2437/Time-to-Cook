//
//  ViewImageViewController.swift
//  TimeToCook
//
//  Created by Kyle Schmid on 5/3/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var recipe:Recipe!
    var callingController:ViewRecipeViewController! = nil
    var newMedia: Bool?
    
    @IBOutlet weak var imageView: UIImageView!
    
    // Called to take a new photo
    @IBAction func btnTakePhotoClicked(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
            imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = true
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
            self.newMedia = true
        }
    }
    
    // Called to choose an existing photo
    @IBAction func btnChoosePhotoClicked(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
            self.newMedia = false
        }
    }
    
    // Executes when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.recipe.getName()
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.image = self.recipe.getImage()
    }
    
    // MARK: UIImagePickerControllerDelegate methods
    
    // Called when an image is available from any of the 3 contexts - camera, camera roll or photo library.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType == kUTTypeImage as String {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            // Update the image view with the new picture from the camera, or selected image
            // from the camera roll or photo library.
            self.imageView.image = image
            self.recipe.setImage(image)
            self.callingController.setNewImage(image)
            
            // If we created a new image with the camera, save it.
            if (self.newMedia == true) {
                // The third argument is the 'completion method selector' - a function that is called when the save
                // operation is done. The method name has an objective-c signature.
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(ViewImageViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    // Called when an image is saved - successfully or not.
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Image Saved", message: "Image Saved", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // Called when you touch the Cancel button in any of the 3 contexts - camera, camera roll or photo library.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}