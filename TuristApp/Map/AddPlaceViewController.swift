//
//  SearchBar.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 13/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces

class AddPlaceViewController: UIViewController {
    // MARK: -Properties
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var selectedPlace: GMSPlace?
    // MARK: -Functions
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    // Pass the selected place to the new view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToPlan" {
            if let nextViewController = segue.destination as? PlanViewController {
                nextViewController.newPoint = selectedPlace
            }
        }
    }
}
// MARK: -Extensions
// Handle the user's selection.
extension AddPlaceViewController: GMSAutocompleteResultsViewControllerDelegate {
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
    searchController?.isActive = false
    // Do something with the selected place.
    selectedPlace = place
    
    performSegue(withIdentifier: "unwindToPlan", sender: self)
    
    print("Place name: \(String(describing: place.name))")
    print("Place address: \(String(describing: place.formattedAddress))")
    print("Place attributions: \(String(describing: place.attributions))")
  }

  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error){
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}
