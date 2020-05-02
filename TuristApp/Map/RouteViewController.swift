//
//  RouteTableViewController.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 13/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import os.log

class RouteViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    // MARK: -Properties
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultsView: UITextView?
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var routeTableView: UITableView!
    
    
    var pointsOfInterest = [GMSPlace]()
    var selectedPoint: GMSPlace?
    
    var plan: Plan?
    
    // Cell reuse id (cells that scroll out of view can be reused).
    let cellReuseIdentifier = "RouteTableViewCell"
    
    
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
        
        // Restrict the search to Bogotá
        //let northEast = CLLocationCoordinate2DMake(4.898922,-73.7053121)
        //let southWest = CLLocationCoordinate2DMake(4.338747,-74.4018276)
        
        //let filter = GMSAutocompleteFilter()
        //filter.country = "co"
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        saveButton.target = self
        saveButton.action = #selector(saveRoute)
        
        routeTableView.delegate = self
        routeTableView.dataSource = self
        routeTableView.separatorColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        routeTableView.backgroundColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        //routeTableView.rowHeight = 100.0
        routeTableView.reloadData()
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        /*if segue.identifier == "unwindToRoutes" {
            if let nextViewController = segue.destination as? RoutesTableViewController {
                let plan = Plan(name: "Plan \(nextViewController.plans.count)", createdAt: Date.init())
                plan?.pointsOfInterest = pointsOfInterest
                nextViewController.newPlan = plan
            }
        }*/
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        plan = Plan(name: "Plan ", createdAt: Date.init())
        plan?.pointsOfInterest = pointsOfInterest
    }*/
    @objc func saveRoute() {
        let alertController = UIAlertController(title: "Name your plan", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { [unowned self, alertController] _ in
            let name = alertController.textFields![0]
            self.plan = Plan(name: name.text ?? "", createdAt: Date())
            self.plan?.pointsOfInterest = self.pointsOfInterest
            self.performSegue(withIdentifier: "unwindToRoutes", sender: self)
        })
        
        present(alertController, animated: true)
    }
    
}

// MARK: -Extensions
// Handle the user's selection.
extension RouteViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place. - Add to the table view
        print("Place name: \(String(describing: place.name))")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        let poi = place
        let newIndexPath = IndexPath(row: pointsOfInterest.count, section: 0)
        pointsOfInterest.append(poi)
        routeTableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
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

extension RouteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPoint = pointsOfInterest[indexPath.row]
        //performSegue(withIdentifier: "pointToInfo", sender: self)
    }
}

extension RouteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointsOfInterest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? RouteTableViewCell else {
             fatalError("The dequeued cell is not an instance of RouteTableViewCell.")
        }
        let poi = pointsOfInterest[indexPath.row]
        
        cell.nameLabel.text = poi.name
        cell.addressLabel.text = "Address: \(poi.formattedAddress ?? "")"

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            pointsOfInterest.remove(at: indexPath.row)
            routeTableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
