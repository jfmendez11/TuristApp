//
//  DetailPlaceViewController.swift
//  TuristApp
//
//  Created by Diana Cepeda on 4/21/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import GooglePlaces

class DetailPlaceViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelP: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionLabel.alpha=0
        labelP.alpha = 0
    resultsViewController = GMSAutocompleteResultsViewController()
    resultsViewController?.delegate = self
    
    let filter = GMSAutocompleteFilter()
        filter.country = "CO"
        resultsViewController?.autocompleteFilter = filter

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))

        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false

           // When UISearchController presents the results view, present it in
           // this view controller, not one further up the chain.
           definesPresentationContext = true
        
    }
}
extension DetailPlaceViewController: GMSAutocompleteResultsViewControllerDelegate{
    
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        //Handle error
        print("Error: ",error.localizedDescription)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace)
    {
        searchController?.isActive = false
        descriptionLabel.alpha = 1
        labelP.alpha = 1
        
        
        descriptionLabel.text = place.formattedAddress
        labelP.text = "Phone Number:\(place.phoneNumber)"
        
        showPlacePhoto(place.placeID!)
        
        
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
            if let place = place {
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
    })
}
        
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
