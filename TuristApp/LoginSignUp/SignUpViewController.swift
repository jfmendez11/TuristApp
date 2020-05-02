//
//  SignUpViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 4/8/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase


@available(iOS 13.0, *)
class SignUpViewController: UIViewController  {

    
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
  override func viewDidLoad() {
           super.viewDidLoad()
           errorLabel.alpha = 0
           setUpElements()
           setUpLanguage()
    
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
                  view.addGestureRecognizer(tap)
      
       }
      
      func setUpElements() {
          Utilities.styleFilledButton(signup)
          
      }
      
      func setUpLanguage(){
       
       signupLabel.text = NSLocalizedString("signup", comment: "signuplab")
       fullName.placeholder = NSLocalizedString("fullName", comment: "full")
       email.placeholder = NSLocalizedString("email", comment: "email")
       password.placeholder = NSLocalizedString("pass", comment: "Password")
       signup.setTitle(NSLocalizedString("signup", comment: "signup"), for: .normal)
      }
      // Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message
      func validateFields() -> String? {
          
          // Check that all fields are filled in
          if fullName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
              password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
              
              return "Please fill in all fields."
          }
          
          // Check if the password is secure
          let cleanedPassword = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
          
          if Utilities.isPasswordValid(cleanedPassword) == false {
              // Password isn't secure enough
              return "Please make sure your password is at least 8 characters, contains a special character and a number."
          }
          
          return nil
      }
      
      @IBAction func signUpTapped(_ sender: Any) {
          switch Network.reachability.status {
                              case .unreachable:
                                  showSimpleAlert()
                              case .wwan:
                                  signupProcess()
                              case .wifi:
                                  signupProcess()
                              }
                     
                              print(" Is Wifi enabled:", Network.reachability.isReachableViaWiFi)
      }
    
     func signupProcess ()
     {
        // Validate the fields
                 let error = validateFields()
                 
                 if error != nil {
                     
                     // There's something wrong with the fields, show error message
                     showError(error!)
                 }
                 else {
                     
                     // Create cleaned versions of the data
                     let name = fullName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                     let emailN = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                     let passwordN = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                     
                     // Create the user
                     Auth.auth().createUser(withEmail: emailN, password: passwordN) { (result, err) in
                         
                         // Check for errors
                         if err != nil {
                             
                           Auth.auth().fetchSignInMethods(forEmail: emailN, completion: { (signInMethods, error) in
                               print(signInMethods!)
                           })
                             // There was an error creating the user
                             self.showError("Error creating user")
                         }
                         else {
                             
                             // User was created successfully, now store the first name and last name
                             let db = Firestore.firestore()
                             
                             db.collection("usuarios").addDocument(data: ["fullName":name, "uid": result!.user.uid ]) { (error) in
                                 
                                 if error != nil {
                                     // Show error message
                                     self.showError("Error saving user data")
                                 }
                               
                             }
                             
                             // Transition to the home screen
                             self.transitionToHome()
                           self.dismiss(animated: false, completion: nil)
                         }
                         
                     }
                     
                 }
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
      
      func showError(_ message:String) {
          
          errorLabel.text = message
          errorLabel.alpha = 1
      }
      
      @available(iOS 13.0, *)
      func transitionToHome() {
          
          
          let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
          
          view.window?.rootViewController = homeViewController
          view.window?.makeKeyAndVisible()
          
      }
  }
