//
//  PhotoLibraryViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 4/21/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMLVision

class PhotoLibraryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var translateText: UITextView!
    @IBOutlet weak var outputPicker: UIPickerView!
    @IBOutlet weak var languageIDOut: UITextField!
    
    @IBOutlet weak var targetDownloadDeleteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusTextView: UITextField!
    
    @IBOutlet weak var activityOffline: UIActivityIndicatorView!
    
    var translator: Translator!
    lazy var allLanguages = TranslateLanguage.allLanguages().compactMap {
        TranslateLanguage(rawValue: $0.uintValue)
      }
    
    var finalImg = UIImage()
    var newText = ""
    
    var textRecognizer: VisionTextRecognizer!
    
    lazy var languageId = NaturalLanguage.naturalLanguage().languageIdentification()
    
    //var textRecognizer: VisionTextRecognizer!
    
    override func viewDidLoad() {
        
        activityIndicator.hidesWhenStopped = true
        activityOffline.hidesWhenStopped = true
        
        text.text = "Enter text here ..."
        text.textColor = UIColor.lightGray
               
        textViewDidBeginEditing(text)
        textViewDidEndEditing(text)
        
        super.viewDidLoad()
        imageView.image = finalImg
       
        let vision = Vision.vision()
           textRecognizer = vision.onDeviceTextRecognizer()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
       outputPicker.dataSource = self
        
        pickerView(outputPicker, didSelectRow: outputPicker.selectedRow(inComponent: 0), inComponent: 0)
       
       //Picker disponibles
        outputPicker.selectRow(allLanguages.firstIndex(of: TranslateLanguage.en)!, inComponent: 0, animated: false)
       
       outputPicker.delegate = self
       
      // pickerView(outputPicker, didSelectRow: 0, inComponent: 0)
       //Define si descargar o no
       setDownloadDeleteButtonLabels()

       NotificationCenter.default.addObserver(self, selector:#selector(remoteModelDownloadDidComplete(notification:)), name:.firebaseMLModelDownloadDidSucceed, object:nil)
       NotificationCenter.default.addObserver(self, selector:#selector(remoteModelDownloadDidComplete(notification:)), name:.firebaseMLModelDownloadDidFail, object:nil)
        
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
             if textView.textColor == UIColor.lightGray {
                 textView.text = nil
                 textView.textColor = UIColor.black
             }
         }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = "Enter text here ..."
                textView.textColor = UIColor.lightGray
               
            }
        }

    override func viewWillAppear(_ animated: Bool) {
        runTextRecognition(with: finalImg)
    }
    
       func showSimpleAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "You can not download lanaguage model because you are not connected to the internet. Please try again later.", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
               
           }))
           self.present(alert, animated: true, completion: nil)
       }
    

    
    func identifyLanguage(_ text: String){
       
         languageId.identifyPossibleLanguages(for: text) { (identifiedLanguages, error) in
             if let error = error {
               self.translateText.text = "Failed with error: \(error)"
               return
             }
             guard let identifiedLanguages = identifiedLanguages, !identifiedLanguages.isEmpty else {
               self.languageIDOut.text = "No language was identified";
               return
    }
             self.languageIDOut.text = "Identified Languages:\n" +
               identifiedLanguages.map {
                 String(format: "(%@, %.2f)", $0.languageCode, $0.confidence)
                 }.joined(separator: "\n");
           }
    }
    
    func runTextRecognition(with image: UIImage)
   {
        let visionImage = VisionImage(image: image)
    
    let metadata = VisionImageMetadata()
           metadata.orientation = self.detectorOrientation(in: image)
           visionImage.metadata = metadata
        textRecognizer.process(visionImage) { (features, error) in
               if features != nil
               {
                  guard let text = features else {
                      self.showSimpleAlert2()
                      return
                  }
                         self.text.text = text.text
                        self.newText=text.text
                     } 
               }
    identifyLanguage(self.newText)
    }
                
    
    func showSimpleAlert2() {
     let alert = UIAlertController(title: "Couldn't take picture", message: "There was a problem with the picture, please take a new one or try again later", preferredStyle: UIAlertController.Style.alert)

     alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
        self.transitionToTranslate()      }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @available(iOS 13.0, *)
    func transitionToTranslate() {

        let pickCamViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.pickCameraController) as? PickCamPhotoViewController
        
        view.window?.rootViewController = pickCamViewController
        view.window?.makeKeyAndVisible()
        
    }
    
    func detectorOrientation(in image: UIImage) -> VisionDetectorImageOrientation {
        switch image.imageOrientation {
        case .up:
            return .topLeft
        case .down:
            return .bottomRight
        case .left:
            return .leftBottom
        case .right:
            return .rightTop
        case .upMirrored:
            return .topRight
        case .downMirrored:
            return .bottomLeft
        case .leftMirrored:
            return .leftTop
        case .rightMirrored:
            return .rightBottom
        }
    }
    
      func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
      }

      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allLanguages[row].toLanguageCode()
      }

      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allLanguages.count
      }

      func textViewDidChange(_ textView: UITextView) {
        translate()
      }

      func model(forLanguage: TranslateLanguage) -> TranslateRemoteModel {
        return TranslateRemoteModel.translateRemoteModel(language: forLanguage)
      }

      func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool {
        let model = self.model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        return modelManager.isModelDownloaded(model)
      }
        
    
      func handleDownloadDelete(picker: UIPickerView, button: UIButton) {
        let language = allLanguages[picker.selectedRow(inComponent: 0)]
        let model = self.model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        
        if modelManager.isModelDownloaded(model) {
            
          self.statusTextView.text = "Deleting " + language.toLanguageCode()
          modelManager.deleteDownloadedModel(model) { error in
            self.statusTextView.text = "Deleted " + language.toLanguageCode()
            self.setDownloadDeleteButtonLabels()
          }
            
        } else {
        switch Network.reachability.status {
                 case .unreachable:
                     showSimpleAlert()
                     break
                 case .wwan:
                    activityIndicator.startAnimating()
                     self.statusTextView.text = "Downloading " + language.toLanguageCode()
                                                     let conditions = ModelDownloadConditions(
                                                       allowsCellularAccess: true,
                                                       allowsBackgroundDownloading: true
                                                     )
                                                     modelManager.download(model, conditions:conditions)
                 case .wifi:

                    activityIndicator.startAnimating()
                     self.statusTextView.text = "Downloading " + language.toLanguageCode()
                                                     let conditions = ModelDownloadConditions(
                                                       allowsCellularAccess: true,
                                                       allowsBackgroundDownloading: true
                                                     )
                                                     modelManager.download(model, conditions:conditions)
                 }
        
                 print(" Is Wifi enabled:", Network.reachability.isReachableViaWiFi)
        }
      }
      @IBAction func didTapDownloadDeleteTargetLanguage() {
        self.handleDownloadDelete(picker: outputPicker, button: self.targetDownloadDeleteButton)
      }

      @IBAction func listDownloadedModels() {
        let msg = "Downloaded models:" + ModelManager.modelManager()
          .downloadedTranslateModels
          .map { model in model.language.toLanguageCode() }
          .joined(separator: ", ");
        self.languageIDOut.text = msg
      }

      @objc
      func remoteModelDownloadDidComplete(notification: NSNotification) {
        let userInfo = notification.userInfo!
        guard let remoteModel =
          userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel else {
            return
        }
        DispatchQueue.main.async {
          if notification.name == .firebaseMLModelDownloadDidSucceed {
            self.statusTextView.text = "Download succeeded for " + remoteModel.language.toLanguageCode()
            self.activityIndicator.stopAnimating()
          } else {
            self.statusTextView.text = "Download failed for " + remoteModel.language.toLanguageCode()
          }
          self.setDownloadDeleteButtonLabels()
        }
      }
//Definir si descargar o delete
      func setDownloadDeleteButtonLabels() {
        
        let outputLanguage = allLanguages[outputPicker.selectedRow(inComponent: 0)]
      
        if self.isLanguageDownloaded(outputLanguage) {
          self.targetDownloadDeleteButton.setTitle("Delete model", for: .normal)
        } else {
          self.targetDownloadDeleteButton.setTitle("Download", for: .normal)
        }
        
      }
    
    
// Elegir lenguaje source y lenguaje destino
      func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let outputLanguage = allLanguages[outputPicker.selectedRow(inComponent: 0)]
        self.setDownloadDeleteButtonLabels()
        let options = TranslatorOptions(sourceLanguage: .es, targetLanguage: outputLanguage)
        translator = NaturalLanguage.naturalLanguage().translator(options: options)
      }
    
    @IBAction func translateTapped(_ sender: Any) {
                translate()
  
    }
    
      func translate() {
        let translatorForDownloading = self.translator!

        translatorForDownloading.downloadModelIfNeeded { error in
          guard error == nil else {
            self.showSimpleAlertTranslate()
            return
          }
            self.activityOffline.alpha = 1
                   
            self.activityOffline.startAnimating()
          self.setDownloadDeleteButtonLabels()
          if translatorForDownloading == self.translator {
            translatorForDownloading.translate(self.newText) { result, error in
              guard error == nil else {return}
              if translatorForDownloading == self.translator {
                self.translateText.text = result
              }
            }
          }
            self.activityOffline.stopAnimating()
        }
      }
    
    func showSimpleAlertTranslate() {
       let alert = UIAlertController(title: "Couldn't translate to language selected", message: "You haven't downloaded the translation model of the language you want. When having internet connection, please try again.", preferredStyle: UIAlertController.Style.alert)

       alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
          self.transitionToTranslate()      }))
          self.present(alert, animated: true, completion: nil)
      }
}
