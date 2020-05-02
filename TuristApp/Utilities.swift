//
//  Utilities.swift
//  TuristApp
//
//  Created by Diana Cepeda on 4/9/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import Foundation
import UIKit

public class Utilities {
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 94/255, green: 92/255, blue: 230/255, alpha: 1)
        button.layer.cornerRadius = 25.0
    }
    
    static func styleTranslationButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red:48/255, green: 51/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 20.0
    }
    
    static func styleHollowButton(_ button:UIButton) {
    
    // Hollow rounded corner style
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.darkGray.cgColor
    button.layer.cornerRadius = 25.0
    button.tintColor = UIColor.black
}
}
