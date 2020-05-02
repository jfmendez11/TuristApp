//
//  TranslationViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 4/12/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import FirebaseMLNLTranslate
import Firebase

class TranslationViewController: UIViewController {

    @IBOutlet weak var labelP: UITextView!
    
    @IBOutlet weak var languageFrom: UILabel!
    @IBOutlet weak var languageTo: UILabel!
    @IBOutlet weak var changeLanguage: UIButton!
    
    
    @IBOutlet weak var enterLabel: UITextField!
    
    @IBOutlet weak var translationLabel: UITextView!
    
    
    @IBOutlet weak var cameraButt: UIButton!
    @IBOutlet weak var voiceButt: UIButton!
    
    var sourceL: TranslatorOptions!
    var targetL: TranslatorOptions!
    
    
    var inputText : String = ""
    
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        inputText = labelP.text!
        setUpLanguage()
    
        Utilities.styleTranslationButton(cameraButt)
        Utilities.styleTranslationButton(voiceButt)
        
        enterLabel.layer.cornerRadius = 22.0
        translationLabel.layer.cornerRadius = 22.0
        
        translationLabel.alpha=0
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
                      view.addGestureRecognizer(tap)

        let localModels = ModelManager.modelManager().downloadedTranslateModels
        print(localModels)
            // Do any additional setup after loading the view.
        }
    
    func setUpLanguage()
    {
        
        labelP.text = NSLocalizedString("what", comment: "where")
        enterLabel.text = NSLocalizedString("enter", comment: "enter")
        voiceButt.setTitle(NSLocalizedString("voice", comment: "voice"), for: .normal)
        cameraButt.setTitle(NSLocalizedString("cam", comment: "cam"), for: .normal)
    }

    @IBAction func didTouchChangeButton(_ sender: Any)
    {
        let firstLabelText = languageFrom.text

        languageFrom.text = languageTo.text
        languageTo.text = firstLabelText
        
    }
    
    @IBAction func didTouchTranslateButton(_ sender: Any) {
       
        
        let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: .es)
        let translator = NaturalLanguage.naturalLanguage().translator(options: options)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        translator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
            
            let text = self.enterLabel.text
            translator.translate(text!) { translatedText, error in
            guard error == nil, let translatedText = translatedText else { return }
                self.translationLabel.text = translatedText
            // Translation succeeded.
        }
        }

        self.translationLabel.alpha=1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed

        }
    }
    
}
