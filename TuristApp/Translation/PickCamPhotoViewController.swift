//
//  PickCamPhotoViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 4/21/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import Firebase

class PickCamPhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var cameraButt: UIButton!
    @IBOutlet weak var photoLibButt: UIButton!
    @IBOutlet weak var textButt: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var img = UIImage()
    var imagePickerController = UIImagePickerController()
    
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        Utilities.styleHollowButton(textButt)
        Utilities.styleFilledButton(cameraButt)
        Utilities.styleHollowButton(photoLibButt)
        imageView.alpha = 0
        

    }

    
    @IBAction func tomarFoto(_ sender: Any) {
        
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
    
        imagePickerController.dismiss(animated: true, completion: nil)
        imageView.image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage
        img = imageView.image!
        performSegue(withIdentifier: "cameraToTranslate", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cameraToTranslate"{
            
            let vc = segue.destination as! PhotoLibraryViewController
            vc.finalImg = img
            
        } else {
            print("")
        }
    }
    
    @IBAction func elegirFoto(_ sender: Any) {
        
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
}
