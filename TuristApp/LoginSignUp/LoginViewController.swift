//
//  LoginViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 29/02/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import FirebaseAuth

@available(iOS 13.0, *)
class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let reachability = try! Reachability()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setUpElements()
            errorLabel.alpha = 0
            setUpLanguage()

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
                      view.addGestureRecognizer(tap)
        
        NotificationCenter.default
                   .addObserver(self,
                                selector: #selector(statusManager),
                                name: .flagsChanged,
                                object: nil)
               updateUserInterface()
            // Do any additional setup after loading the view.
      
        }
    override func viewDidAppear(_ animated: Bool) {
        updateUserInterface()
    }
        
        func setUpElements() {
            Utilities.styleFilledButton(login)
            
        }
        func setUpLanguage() {
               loginLabel.text = NSLocalizedString("login", comment: "login")
               email.placeholder = NSLocalizedString("email", comment: "email")
               password.placeholder = NSLocalizedString("pass", comment: "pass")
               login.setTitle(NSLocalizedString("login", comment: "login"), for: .normal)
        }
        @IBAction func loginTapped(_ sender: Any) {
            
            
            switch Network.reachability.status {
                     case .unreachable:
                         showSimpleAlert()
                     case .wwan:
                         realizarLogin()
                     case .wifi:
                         realizarLogin()
                     }
            
                     print(" Is Wifi enabled:", Network.reachability.isReachableViaWiFi)
           
     }
    func updateUserInterface() {
         
       }
    func realizarLogin () {
        
        let emailN = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordN = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
                   Auth.auth().signIn(withEmail: emailN, password: passwordN) { (result, error) in
                       
                       if error != nil {
                           // Couldn't sign in
                           self.errorLabel.text = error!.localizedDescription
                           self.errorLabel.alpha = 1
                       }
                       else {
                           let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
                           
                           self.view.window?.rootViewController = homeViewController
                           self.view.window?.makeKeyAndVisible()
                        
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.synchronize()
               }
               
               
             }
    }
    
    @objc func statusManager(_ notification: Notification) {
           updateUserInterface()
       }
    
    func showSimpleAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "You are not connected to the internet. Please try again later.", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
               self.transitionToStart()
           }))
           self.present(alert, animated: true, completion: nil)
       }
    
    func transitionToStart() {
             
             
             let startViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.startViewController) as? StartViewController
             
             view.window?.rootViewController = startViewController
             view.window?.makeKeyAndVisible()
             
         }
}
