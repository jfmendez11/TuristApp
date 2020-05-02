//
//  PlanTableViewController.swift
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

class PlanViewController: UIViewController, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    private var fetchedRC: NSFetchedResultsController<Place>!
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // MARK: Properties
    @IBOutlet weak var pointsTableView: UITableView!
    @IBOutlet weak var addNewPlaceBarButtonItem: UIBarButtonItem!
    
    let baseURLCode = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var routes: [JSON] = []
    
    var plan: PlannedRoute?
    //var pointsOfInterest = [Place]()
    var selectedPoint: Place?
    var currentLocation: CLLocation?
    
    var newPoint: GMSPlace?
    
    let monitor = NWPathMonitor()
    var connected: Bool?
    
    // Cell reuse id (cells that scroll out of view can be reused).
    let cellReuseIdentifier = "PlanTableViewCell"
    
    @IBAction func uniwndToPlan(segue: UIStoryboardSegue) {
        /*let newIndexPath = IndexPath(row: pointsOfInterest.count, section: 0)
        guard let poi = newPoint else {
            fatalError("Invalid point")
        }
        pointsOfInterest.append(poi)
        pointsTableView.insertRows(at: [newIndexPath], with: .automatic)
        
        plan?.pointsOfInterest.append(poi)*/
        let place = Place(context: self.context)
        place.name = newPoint!.name
        place.latitude = newPoint!.coordinate.latitude
        place.longitude = newPoint!.coordinate.longitude
        place.formattedAddress = newPoint!.formattedAddress
        place.phone = newPoint!.phoneNumber
        place.website = newPoint!.website?.absoluteString
        place.rating = newPoint!.rating
        place.plan = plan
        for type in newPoint!.types! {
            let typeToAdd = Type(context: self.context)
            typeToAdd.type = type
            typeToAdd.place = place
        }
        savePhoto(place: place, gmsPlace: newPoint!)
    }
    
    func savePoint() {
        guard let places = fetchedRC.fetchedObjects else {
            fatalError("Not fecthing object")
        }
        guard let key = ProcessInfo.processInfo.environment["GOOGLE_MAPS_KEY"] else {
            fatalError("Problems with Google Maps API Key")
        }
        //let points = plan!.places
        let origin = "origin=\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)"
        let destination = "&destination=\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)"
        
        var waypoints = "&waypoints=\(places[0].latitude),\(places[0].longitude)"
        for i in 1..<places.count {
            waypoints += "|\(places[i].latitude),\(places[i].longitude)"
        }
        
        let session = URLSession.shared
        let originalURL = "\(baseURLCode)\(origin)\(destination)\(waypoints)&key=\(key)"
        let urlString = originalURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url  = URL(string: urlString)!
        
        let task = session.dataTask(with: url, completionHandler: {data, response, error in
            let json = try! JSON(data: data!)
            let routes = json["routes"].arrayValue
            //let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
            let request = NSFetchRequest<Point>(entityName: "Point")
            request.predicate = NSPredicate(format: "plan.planName == %@", self.plan!.planName! as NSString)
            do {
                let points = try self.context.fetch(request)
                points.forEach{point in
                    self.context.delete(point)
                    //point.plan = nil
                }
                //let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                //try self.context.execute(batchDeleteRequest)
            } catch let error as NSError {
                print("Could not fetch points. \(error), \(error.userInfo)")
            }
            for route in routes {
                let point = Point(context: self.context)
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                point.point = points
                point.plan = self.plan
            }
            print("fue el de save point")
            self.appDelegate.saveContext()
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
                print("fue el de save photo")
                self.appDelegate.saveContext()
                self.savePoint()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if plan?.planName != nil {
            navigationItem.title = plan?.planName
        }
        monitor.pathUpdateHandler = {path in
            if path.status == .satisfied {
                self.connected = true
            } else {
                self.connected = false
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        addNewPlaceBarButtonItem.target = self
        addNewPlaceBarButtonItem.action = #selector(addNewPlace)
        //pointsTableView.register(PlanTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        performFetch()
        // This view controller provides delegate methods and row data for the table view.
        pointsTableView.delegate = self
        pointsTableView.dataSource = self
        pointsTableView.separatorColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        pointsTableView.backgroundColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
        //pointsTableView.rowHeight = 100.0
        pointsTableView.reloadData()
        
        view.backgroundColor = UIColor(red: CGFloat(231)/255.0, green: CGFloat(231)/255.0, blue: CGFloat(231)/255.0, alpha: CGFloat(1.0))
    }
    
    @objc func addNewPlace() {
        if connected! {
            self.performSegue(withIdentifier: "newPoint", sender: self)
        } else {
            showAlert(title: "No Internet Connection", message: "Unable to add a new place without internet connection. Verify your connection.")
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
                pointsTableView.insertRows(at: [cellIndex], with: .fade)
                //savePoint()
            default:
            break
        }
    }
    
    func performFetch() {
        let request = Place.fetchRequest() as NSFetchRequest<Place>
        let sort = NSSortDescriptor(key: #keyPath(Place.placeId), ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "plan.planName == %@", plan!.planName! as NSString)
        
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
            fetchedRC.delegate = self
        } catch let error as NSError {
            print("Could not fetch places. \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case "newPoint":
            os_log("Adding a new point", log: OSLog.default, type: .debug)
        case "pointToInfo":
            os_log("Going to point info, need to be implemented", log: OSLog.default, type: .debug)
            guard let pointInfoVC = segue.destination as? PointInfoViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedPlaceCell = sender as? PlanTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = pointsTableView.indexPath(for: selectedPlaceCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedPoint = fetchedRC.object(at: indexPath)
            pointInfoVC.selectedPlace = selectedPoint
        case "unwindToMapWithRoute":
            os_log("Going to map with route", log: OSLog.default, type: .debug)
        default:
            fatalError("Unexpected segue identifier; \(String(describing: segue.identifier))")
        }
    }
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    
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
    @IBAction func tapStartRoute(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMapWithRoute", sender: self)
    }
    
    
}
//MARK: -Extensions
extension PlanViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*selectedPoint = plan!.pointsOfInterest[indexPath.row]
        performSegue(withIdentifier: "pointToInfo", sender: self)*/
    }
}

extension PlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let places = fetchedRC.fetchedObjects else {return 0}
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? PlanTableViewCell else {
             fatalError("The dequeued cell is not an instance of PlanTableViewCell.")
        }
        let place = fetchedRC.object(at: indexPath)
        
        cell.nameLabel.text = place.name
        cell.addressLabel.text = "Address: \(place.formattedAddress ?? "")"
        if let data = place.photo as Data? {
            cell.placeImage.image =  UIImage(data: data)
        } else {
            cell.placeImage.image = UIImage(named: "no-image-icon.png")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
}
