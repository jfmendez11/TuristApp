//
//  TipsViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 4/4/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import GooglePlaces


class TipsViewController: UIViewController{
    
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var popupView: UIView!

    @IBOutlet weak var tipImage: UIImageView!
    @IBOutlet weak var tipDescription: UILabel!

    @IBOutlet weak var tipNumber: UILabel!
    
    @IBOutlet weak var viewP: UIView!
    
    var selectedCell: [Int] =  []

    // An array to hold the list of likely places.
     var likelyPlaces: [GMSPlace] = []
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    var placesClient: GMSPlacesClient!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate let collectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    
    override func viewDidLoad() {
        
        activityIndicator.hidesWhenStopped = true

            super.viewDidLoad()
   
        viewP.addSubview(collectionView)
        collectionView.backgroundColor = .white
        
        
        collectionView.topAnchor.constraint(equalTo: viewP.topAnchor, constant: 130).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: viewP.leadingAnchor, constant: 20).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: viewP.trailingAnchor, constant: -40).isActive = true
        
        collectionView.heightAnchor.constraint(equalToConstant: viewP.frame.width/2).isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Size of blur view equal to size of view
        blurView.bounds = self.view.bounds
        
        //Set width to 90% of screen, 40% of screen height
        popupView.bounds = CGRect(x: 0, y: 0, width: 365, height: 320)
        
        collectionView.backgroundColor = UIColor.white
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        //LikelyPlaces
        // Initialize the location manager.
           locationManager = CLLocationManager()
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.requestAlwaysAuthorization()
           locationManager.distanceFilter = 50
           locationManager.startUpdatingLocation()
           locationManager.delegate = self

           placesClient = GMSPlacesClient.shared()
        
        switch Network.reachability.status {
        case .unreachable:
            
            showSimpleAlert()
        case .wwan:
            listLikelyPlaces()
        case .wifi:
            listLikelyPlaces()
        }
    
    }
    override func viewDidAppear(_ animated: Bool) {
        /*switch Network.reachability.status {
        case .unreachable:
            
            showSimpleAlert()
        case .wwan:
           activityIndicator.startAnimating()
            listLikelyPlaces()
           activityIndicator.stopAnimating()
        case .wifi:

           activityIndicator.startAnimating()
            listLikelyPlaces()
            activityIndicator.stopAnimating()
        }*/
    }
    
    func showSimpleAlert() {
     let alert = UIAlertController(title: "No Internet Connection", message: "Places close to you cannot be loaded because there's no internet conection. Check your conection and please try again later.", preferredStyle: UIAlertController.Style.alert)

     alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Get likelyplaces
    func listLikelyPlaces() {
      // Clean up from previous sessions.
        
    activityIndicator.alpha = 1
        activityIndicator.startAnimating()
      likelyPlaces.removeAll()

      placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
        if let error = error {
          // TODO: Handle the error.
          print("Current Place error: \(error.localizedDescription)")
          return
        }
        
        // Get likely places and add to the list.
        if let likelihoodList = placeLikelihoods{
          for likelihood in likelihoodList.likelihoods {
            let place = likelihood.place
            
            self.likelyPlaces.append(place)
            print(place.placeID)
            print(place.name)
          }
        }
        self.collectionView.reloadData()
        self.activityIndicator.alpha = 0
      })
    }
    
    func showSimpleAlertAppStore() {
     let alert = UIAlertController(title: "No Internet Connection", message: "To open the App Store it's necesary to have internet connection. Check your conection and please try again later.", preferredStyle: UIAlertController.Style.alert)

     alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        switch Network.reachability.status {
               case .unreachable:
                   showSimpleAlertAppStore()
               case .wwan:
                let urlStr = "https://apps.apple.com/co/app/transmilenio-y-sitp/id731013251"
                  if #available(iOS 10.0, *) {
                      UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)

                  } else {
                      UIApplication.shared.openURL(URL(string: urlStr)!)
                  }
               case .wifi:
                let urlStr = "https://apps.apple.com/co/app/transmilenio-y-sitp/id731013251"
                      if #available(iOS 10.0, *) {
                          UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)

                      } else {
                          UIApplication.shared.openURL(URL(string: urlStr)!)
                      }
               }
    }
    
    @IBAction func taxisButtonTapped(_ sender: Any) {
        switch Network.reachability.status {
        case .unreachable:
            showSimpleAlertAppStore()
        case .wwan:
         let urlStr = "https://apps.apple.com/co/app/taxis-libres/id686270238"
         if #available(iOS 10.0, *) {
             UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)

         } else {
             UIApplication.shared.openURL(URL(string: urlStr)!)
         }
        case .wifi:
         let urlStr = "https://apps.apple.com/co/app/taxis-libres/id686270238"
         if #available(iOS 10.0, *) {
             UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)

         } else {
             UIApplication.shared.openURL(URL(string: urlStr)!)
         }
        }
    }
    
    @IBAction func picapTapped(_ sender: Any) {
        switch Network.reachability.status {
        case .unreachable:
            showSimpleAlertAppStore()
        case .wwan:
          let urlStr = "https://apps.apple.com/co/app/picap/id1139476429"
                      if #available(iOS 10.0, *) {
                          UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)

                      } else {
                          UIApplication.shared.openURL(URL(string: urlStr)!)
               }
        case .wifi:
        let urlStr = "https://apps.apple.com/co/app/picap/id1139476429"
                      if #available(iOS 10.0, *) {
                          UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)

                      } else {
                          UIApplication.shared.openURL(URL(string: urlStr)!)
                }
        }
      
    }
    
    @IBAction func firstTipTapped(_ sender: Any) {
        
        tipNumber.text = "When to move arround the city?"
        tipImage.image = UIImage(named: "tip1")
        tipDescription.text = "Travelers are recommended to move around the city only during the daytime. If you want to be out at nighttime, please be more careful"
        
        animateIn(desiredView: blurView)
        animateIn(desiredView: popupView)
    }
    @IBAction func secondTipTapped(_ sender: Any) {
        
        tipNumber.text = "How to manage my currency?"
        tipImage.image = UIImage(named: "tip2")
        tipDescription.text = "Currency should be exchanged in banks only. Under no circumstances use the exchanging services of private people. "
        
        animateIn(desiredView: blurView)
        animateIn(desiredView: popupView)
    }
    @IBAction func thirdTipTapped(_ sender: Any) {
        tipNumber.text = "How to be more secure?"
        tipImage.image = UIImage(named: "tip3")
        tipDescription.text = "Avoiding dodgy areas will help minimise threat of being robbed, but even if you stick to the safest streets you should not wear flashy clothes or expose your valuable personal items."
        
        animateIn(desiredView: blurView)
        animateIn(desiredView: popupView)
    }
    
    @IBAction func fourthTipTapped(_ sender: Any) {
        tipNumber.text = "How to travel around the city?"
        tipImage.image = UIImage(named: "tip4")
        tipDescription.text = "Transmmilenio is one of the coolest ways to travel, but prefer to do it before noon to avoid too much people"
        animateIn(desiredView: blurView)
        animateIn(desiredView: popupView)
    }
    
    
    func saveInfoTips(){
        
        UserDefaults.standard.set("Is recommended to move around the city during daytime", forKey: "Tip 1")
        UserDefaults.standard.set("Currency should be exchanged in banks only", forKey: "Tip 2")
        UserDefaults.standard.set("Is best to avoid certain areas of the city, but you should be careful everyway", forKey: "Tip 3")
        UserDefaults.standard.set("Transmilenio is a good transportation option. Use it preferably during the day", forKey: "Tip 4")
    }
    
    
    @IBAction func doneTip(_ sender: Any) {
        animateOut(desiredView: popupView)
        animateOut(desiredView: blurView)
    }
    
    func animateIn(desiredView: UIView)
    {
        
        let backgroundView = self.view!
        
        //Atach view (popup) to screen
        backgroundView.addSubview(desiredView)
        
        //Sets views scaling to be 120% of its regular size
        desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        desiredView.alpha = 0
        desiredView.center = backgroundView.center
        
        //Animation effect
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
        })
        
        
    }
    
    func animateOut(desiredView: UIView)
    {
        UIView.animate(withDuration: 0.3, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            desiredView.alpha = 0
        }, completion: { _ in
            desiredView.removeFromSuperview()
        })
        
    }
    

    var imagenes: [UIImage] = [UIImage(named: "bogota1")!,UIImage(named: "bogota2")!,UIImage(named: "bogota3")!,UIImage(named: "bogota4")!,UIImage(named: "bogota5")!,UIImage(named: "bogota1")!,UIImage(named: "bogota2")!,UIImage(named: "bogota3")!,UIImage(named: "bogota4")!,UIImage(named: "bogota5")!,UIImage(named: "bogota1")!,UIImage(named: "bogota2")!,UIImage(named: "bogota3")!,UIImage(named: "bogota4")!,UIImage(named: "bogota5")!,UIImage(named: "bogota1")!,UIImage(named: "bogota2")!,UIImage(named: "bogota3")!,UIImage(named: "bogota4")!,UIImage(named: "bogota5")!]
    
    
}
extension TipsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(likelyPlaces.count)
        return likelyPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        
        if indexPath.row < likelyPlaces.count {
        let collectionItem = likelyPlaces[indexPath.row]
        cell.label?.text = collectionItem.name
        }
        
        cell.imageView?.image = imagenes[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
        print("You selected cell #\(indexPath.item)!")

        if (self.selectedCell.contains(indexPath.item))
        {
            print("Item already added")
        }
        else
        {
            self.selectedCell.append(indexPath.item)
        }

        print("selectedCell.count: \(self.selectedCell.count)")

        if (self.selectedCell.count > 0)
        {
            let secondViewController =   self.storyboard?.instantiateViewController(withIdentifier: "ClosePlaceViewController") as! ClosePlaceViewController
            
             if indexPath.row < likelyPlaces.count {
                
                
                let place = self.likelyPlaces[indexPath.row]
                // Bounce back to the main thread to update the UI

                    secondViewController.placeTips = place
                print("Place en tipsssss: \(secondViewController.placeTips)")

                    self.navigationController?.pushViewController(secondViewController, animated: true)
                
                print("selectedCell: \(self.selectedCell)")
            
        }
}
        else
        {
            //nil
        }
        
    }
    
    
}

// Delegates to handle events for the location manager.
extension TipsViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let location: CLLocation = locations.last!
    print("Location: \(location)")

  }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         switch status {
             case .restricted:
               print("Location access was restricted.")
             case .denied:
               print("User denied access to location.")
             case .notDetermined:
               print("Location status not determined.")
             case .authorizedAlways: fallthrough
             case .authorizedWhenInUse:
               print("Location status is OK.")
             @unknown default:
               fatalError()
             }
    }

  // Handle location manager errors.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager.stopUpdatingLocation()
    print("Error: \(error)")
  }
}


