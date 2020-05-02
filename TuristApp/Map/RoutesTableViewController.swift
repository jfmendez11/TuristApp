//
//  RoutesTableViewController.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 13/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import Foundation
import UIKit
import os.log
import GooglePlaces
import SwiftyJSON
import CoreData
import Network

class RoutesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private var fetchedRC: NSFetchedResultsController<PlannedRoute>!
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: -Properties
    //var plans = [Plan]()
    let baseURLCode = "https://maps.googleapis.com/maps/api/directions/json?"
    // Pasar el current location desde el segue anterior
    //var newPlan: Plan?
    let monitor = NWPathMonitor()
    var connected: Bool?
    
    var currentLocation: CLLocation?
    @IBOutlet weak var newRouteBarButtonItem: UIBarButtonItem!
    
    // MARK: -Test Variables
    var places: [GMSPlace] = []
    
    @IBAction func unwindToRoutes(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? RouteViewController, let plan = sourceViewController.plan {
            if plan.pointsOfInterest.count < 1 {
                print("Entro al de count")
                showAlert(title: "Could not save plan", message: "Your plan must have at least one place or point.")
            } else if plan.name.isEmpty {
                print("Entro al de isempty")
                showAlert(title: "Could not save plan", message: "Your plan must have a name.")
            } else if checkRecordExists(planName: plan.name) {
                print("Entro al de existe")
                showAlert(title: "Could not save plan", message: "A plan with that name already exists.")
            } else if !connected! {
                showAlert(title: "Could not save plan", message: "No internet conncection.")
            }
            else {
                print("Entro al else")
                saveRoute(plan: plan)
            }
            
            //let newIndexPath = IndexPath(row: plans.count, section: 0)
            //plans.append(plan)
            //tableView.insertRows(at: [newIndexPath], with: .automatic)
        } else {
            showAlert(title: "Could not save plan", message: "Your plan must have a name.")
        }
    }
    
    func checkRecordExists(planName: String) -> Bool {
        let request = PlannedRoute.fetchRequest() as NSFetchRequest<PlannedRoute>
        request.predicate = NSPredicate(format: "planName == %@", planName as NSString)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(request)
            print(results.count > 0)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return results.count > 0
    }
    
    func saveRoute(plan: Plan) {
        let plannedRoute = PlannedRoute(context: self.context)
        plannedRoute.planName = plan.name
        plannedRoute.createdAt = plan.createdAt
        
        guard let key = ProcessInfo.processInfo.environment["GOOGLE_MAPS_KEY"] else {
            fatalError("Problems with Google Maps API Key")
        }
        let points = plan.pointsOfInterest
        let origin = "origin=\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)"
        let destination = "&destination=\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)"
        
        var waypoints = "&waypoints=\(points[0].coordinate.latitude),\(points[0].coordinate.longitude)"
        for i in 1..<points.count {
            waypoints += "|\(points[i].coordinate.latitude),\(points[i].coordinate.longitude)"
        }
        
        let session = URLSession.shared
        let originalURL = "\(baseURLCode)\(origin)\(destination)\(waypoints)&key=\(key)"
        let urlString = originalURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url  = URL(string: urlString)!
        
        let task = session.dataTask(with: url, completionHandler: {data, response, error in
            let json = try! JSON(data: data!)
            let routes = json["routes"].arrayValue
            plan.setRoutes(routes: routes)
            
            for route in routes {
                let point = Point(context: self.context)
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                point.point = points
                point.plan = plannedRoute
            }
            self.appDelegate.saveContext()
            
            for poi in points {
                let place = Place(context: self.context)
                place.placeId = poi.placeID
                place.latitude = poi.coordinate.latitude
                place.longitude = poi.coordinate.longitude
                place.formattedAddress = poi.formattedAddress
                place.name = poi.name
                place.website = poi.website?.absoluteString
                place.rating = poi.rating
                place.phone = poi.phoneNumber
                for type in poi.types! {
                    let typeToAdd = Type(context: self.context)
                    typeToAdd.type = type
                    typeToAdd.place = place
                }
                place.plan = plannedRoute
                self.savePhoto(place: place, gmsPlace: poi)
            }
        })
        task.resume()
    }
    
    private func savePhoto(place: Place, gmsPlace: GMSPlace) {
        let placesClient = GMSPlacesClient()
        let photoMetadata: GMSPlacePhotoMetadata = gmsPlace.photos![0]
        print("Photo count: \(String(describing: gmsPlace.photos?.count))")
        placesClient.loadPlacePhoto(photoMetadata, callback: {(photo,error) -> Void in
            if let error = error {
                print("entró al if")
                print("Error loading photo metadata \(error.localizedDescription)")
                return
            } else {
                place.photo = photo?.pngData() as NSData? as Data?
                self.appDelegate.saveContext()
            }
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.rowHeight = 80.0
        monitor.pathUpdateHandler = {path in
            if path.status == .satisfied {
                self.connected = true
            } else {
                self.connected = false
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        newRouteBarButtonItem.target = self
        newRouteBarButtonItem.action = #selector(addNewPlan)
        
        
        // To delete later
        //loadSampleRoutes()
        //tableView.register(RoutesTableViewCell.self, forCellReuseIdentifier: "RoutesTableViewCell")
        tableView.separatorColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        tableView.backgroundColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
    }
    
    @objc func addNewPlan() {
        if connected! {
            self.performSegue(withIdentifier: "newRoute", sender: self)
        } else {
            showAlert(title: "No Internet Connection", message: "Unable to create a new plan without internet connection. Verify your connection.")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
      
        let index = indexPath ?? (newIndexPath ?? nil)
        guard let cellIndex = index else { return }
        switch type {
            case .insert:
                tableView.insertRows(at: [cellIndex], with: .fade)
            case .delete:
                tableView.deleteRows(at: [cellIndex], with: .fade)
            default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let request = PlannedRoute.fetchRequest() as NSFetchRequest<PlannedRoute>
        let sort = NSSortDescriptor(key: #keyPath(PlannedRoute.createdAt), ascending: true)
        request.sortDescriptors = [sort]
        
        do {
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        try fetchedRC.performFetch()
        fetchedRC.delegate = self
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let plans = fetchedRC.fetchedObjects else {return 0}
        return plans.count
    }
    
    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "RoutesTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? RoutesTableViewCell else {
            fatalError("The dequed cell is not an instance of RoutesTabeViewCell")
        }
        // Fetches the appropriate Planned route for the data source layout
        let plan = fetchedRC.object(at: indexPath)
        cell.nameLabel.text = plan.planName
        cell.countLabel.text = "\(plan.places!.count) point\(plan.places!.count != 1 ? "s":"")"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        cell.createdAtLabel.text = "Created: \(dateFormatter.string(from: plan.createdAt!))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let plan = fetchedRC.object(at: indexPath)
            context.delete(plan)
            appDelegate.saveContext()
            tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    /*
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    // MARK: -Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "newRoute":
            os_log("Adding a new route", log: OSLog.default, type: .debug)
        case "routesToPlan":
            guard let planViewController = segue.destination as? PlanViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedPlanCell = sender as? RoutesTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedPlanCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedPlan = fetchedRC.object(at: indexPath)
            planViewController.plan = selectedPlan
            //planViewController.pointsOfInterest = selectedPlan.places?.allObjects as! [Place]
            planViewController.currentLocation = currentLocation
        default:
            fatalError("Unexpected segue identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: -Private Method
    private func loadSampleRoutes() {
        guard let route1 = Plan(name: "Plan 1", createdAt: Date.init()) else {
            fatalError("unable to instantiate route1")
        }
        route1.pointsOfInterest += [places[0], places[1], places[2]]
        guard let route2 = Plan(name: "Plan 2", createdAt: Date.init()) else {
            fatalError("unable to instantiate route2")
        }
         route2.pointsOfInterest += [places[3], places[4], places[5]]
        guard let route3 = Plan(name: "Plan 3", createdAt: Date.init()) else {
            fatalError("unable to instantiate route3")
        }
        route3.pointsOfInterest += [places[6], places[7], places[8]]

        //plans += [route1, route2, route3]
    }
}
