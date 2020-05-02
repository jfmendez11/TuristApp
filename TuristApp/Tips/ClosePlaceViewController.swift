//
//  ClosePlaceViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 26/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import GooglePlaces

class ClosePlaceViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelP: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    let group = DispatchGroup() // initialize
    
    var placeTips: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        group.enter() // wait
        if placeTips != nil {
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.labelP.text = self.placeTips?.formattedAddress
        self.descriptionLabel.text = self.placeTips?.name
        self.showPlacePhoto((self.placeTips?.placeID)!)
        }
        // Do any additional setup after loading the view.
    }
    
    func showPlacePhoto(_ placeID: String)
        {
            let placesClient = GMSPlacesClient()
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue))!
            
            placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
                (place: GMSPlace?, error: Error?) in
                if let error = error{
                    print("An error occurred: \(error.localizedDescription)")
                    return
                }
                if let place = self.placeTips {
                    if place.photos?.count == nil{
                        self.imageView.image = #imageLiteral(resourceName: "bogota5")
                    }else {
                        let photoMetadata: GMSPlacePhotoMetadata = place.photos! [0]
                            placesClient.loadPlacePhoto(photoMetadata, callback: { (photo,error) ->Void in
                            if let error = error {
                                print("Error loading photo metadata \(error.localizedDescription)")
                                return
                            } else {
                                self.imageView.image = photo;
                                }
                        })
                    }
            }
        })
    }

}
