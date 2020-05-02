//
//  StartViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 4/8/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import FirebaseAuth


@available(iOS 13.0, *)
class StartViewController: UIViewController {

    @IBOutlet weak var labelP: UILabel!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var signup: UIButton!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setUpElements()
            setUpLanguage()
            // Do any additional setup after loading the view.
        }

    fileprivate func isLoggedIn() -> Bool {
        print("AAAAAAAA \(UserDefaults.standard.bool(forKey: "isLoggedIn"))")
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            if Auth.auth().currentUser != nil {
                let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
                            
                            view.window?.rootViewController = homeViewController
                            view.window?.makeKeyAndVisible()
            }

        }
        
        func setUpElements() {
            Utilities.styleFilledButton(login)
            Utilities.styleHollowButton(signup)
            
        }
        func setUpLanguage(){
            labelP.text = NSLocalizedString("where", comment: "where")
            login.setTitle(NSLocalizedString("login", comment: "login"), for: .normal)
            signup.setTitle(NSLocalizedString("signup", comment: "signup"), for: .normal)
        }


    }
