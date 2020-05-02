//
//  Translation2ViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 22/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import Firebase

class Translation2ViewController: UIViewController, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var inputPicker: UIPickerView!
    @IBOutlet weak var outputPicker: UIPickerView!
    @IBOutlet weak var sourceDownloadDeleteButton: UIButton!
    @IBOutlet weak var targetDownloadDeleteButton: UIButton!
    @IBOutlet weak var transButt: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityOffline: UIActivityIndicatorView!
    
    var translator: Translator!
    lazy var allLanguages = TranslateLanguage.allLanguages().compactMap {
        TranslateLanguage(rawValue: $0.uintValue)
      }

      override func viewDidLoad() {
        
        activityIndicator.hidesWhenStopped = true
        activityOffline.hidesWhenStopped = true
        
        inputTextView.text = "Enter text here ..."
        inputTextView.textColor = UIColor.lightGray
        
        textViewDidBeginEditing(inputTextView)
        textViewDidEndEditing(inputTextView)
        
        inputPicker.dataSource = self
        outputPicker.dataSource = self
        
        //Picker disponibles
        inputPicker.selectRow(allLanguages.firstIndex(of: TranslateLanguage.en) ?? 0, inComponent: 0, animated: false)
        outputPicker.selectRow(allLanguages.firstIndex(of: TranslateLanguage.es) ?? 0, inComponent: 0, animated: false)
        
        inputPicker.delegate = self
        outputPicker.delegate = self
        
        pickerView(inputPicker, didSelectRow: 0, inComponent: 0)
        //Define si descargar o no
        setDownloadDeleteButtonLabels()

        NotificationCenter.default.addObserver(self, selector:#selector(remoteModelDownloadDidComplete(notification:)), name:.firebaseMLModelDownloadDidSucceed, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(remoteModelDownloadDidComplete(notification:)), name:.firebaseMLModelDownloadDidFail, object:nil)
        
        // Cuando tap en algun punto de la pantalla, desaparece teclado
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        
               
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
    
      func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
      }

      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allLanguages[row].toLanguageCode()
      }

      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allLanguages.count
      }

      func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                    replacementText text: String) -> Bool {
        // Hide the keyboard when "Done" is pressed.
        if (text == "\n") {
          textView.resignFirstResponder()
          return false
        }
        return true
      }

      func textViewDidChange(_ textView: UITextView) {
        translate()
      }

    //Cambiar idioma de picker
      @IBAction func didTapSwap() {
        let inputSelectedRow = inputPicker.selectedRow(inComponent: 0)
        inputPicker.selectRow(outputPicker.selectedRow(inComponent: 0), inComponent: 0, animated: false)
        outputPicker.selectRow(inputSelectedRow, inComponent: 0, animated: false)
        inputTextView.text = outputTextView.text
        pickerView(inputPicker, didSelectRow: 0, inComponent: 0)
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
 
    func showSimpleAlert() {
     let alert = UIAlertController(title: "No Internet Connection", message: "You can not download lanaguage model because you are not connected to the internet. Please try again later.", preferredStyle: UIAlertController.Style.alert)

     alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
        
    @IBAction func didTapDownloadDeleteSourceLanguage(_ sender: Any) {
        self.handleDownloadDelete(picker: inputPicker, button: self.sourceDownloadDeleteButton)
    }
    
      @IBAction func didTapDownloadDeleteTargetLanguage() {
        self.handleDownloadDelete(picker: outputPicker, button: self.targetDownloadDeleteButton)
      }

      @IBAction func listDownloadedModels() {
        let msg = "Downloaded models:" + ModelManager.modelManager()
          .downloadedTranslateModels
          .map { model in model.language.toLanguageCode() }
          .joined(separator: ", ");
        self.statusTextView.text = msg
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
        let inputLanguage = allLanguages[inputPicker.selectedRow(inComponent: 0)]
        let outputLanguage = allLanguages[outputPicker.selectedRow(inComponent: 0)]
        if self.isLanguageDownloaded(inputLanguage) {
          self.sourceDownloadDeleteButton.setTitle("Delete model", for: .normal)
        } else {
          self.sourceDownloadDeleteButton.setTitle("Download model", for: .normal)
        }
        if self.isLanguageDownloaded(outputLanguage) {
          self.targetDownloadDeleteButton.setTitle("Delete model", for: .normal)
        } else {
          self.targetDownloadDeleteButton.setTitle("Download model", for: .normal)
        }
      }
// Elegir lenguaje source y lenguaje destino
      func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let inputLanguage = allLanguages[inputPicker.selectedRow(inComponent: 0)]
        let outputLanguage = allLanguages[outputPicker.selectedRow(inComponent: 0)]
        self.setDownloadDeleteButtonLabels()
        let options = TranslatorOptions(sourceLanguage: inputLanguage, targetLanguage: outputLanguage)
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
            translatorForDownloading.translate(self.inputTextView.text ?? "") { result, error in
              guard error == nil else {return}
                
              if translatorForDownloading == self.translator {
                self.outputTextView.text = result

                self.activityOffline.stopAnimating()
                
              }
            }
          }
        }
      }
    
       func showSimpleAlertTranslate() {
          let alert = UIAlertController(title: "Couldn't translate to language selected", message: "You haven't downloaded the translation model of the language you want. When having internet connection, please try again.", preferredStyle: UIAlertController.Style.alert)

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
}
