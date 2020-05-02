//
//  MapViewController.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 6/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import CoreMotion

class MapViewController: UIViewController, GMSMapViewDelegate {
    // MARK: Metodos interesantes
    /*
     1. Map types:
        mapView.mapType = .normal|.hybrid|.satellite
     2. Indoor maps:
        mapView.isDoorEnabled = false|true
     3. Traffic Layer:
        mapView.isTrafficEnabled = true|false
     4. Accessibility:
        mapView.accessibilityElementsHidden = false|true
     5. User's Location:
        if let userLocation = mapView.myLocation {
            print("User's Location: \(userLocation)")
        } else {
            print("User's Location Unkown")
        }
        (Lo otro ya está)
     6. Map Padding:
        let mapInsets = UIEdgeInsets(top: 100.0, left: 0.0, bottom: 0.0, right: 300.0)
        mapView.padding = mapInsets
     */
    
    // MARK: Attributes
    
    // LO QUE ESTA COMENTADO DE PLACES ES PARA VERLO DESPUES
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    let motionManager = CMMotionManager()
    
    let baseURLCode = "https://maps.googleapis.com/maps/api/directions/json?"
    
    // Marker to show info when a point of interest is clicked
    let infoMarker = GMSMarker()
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []

    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    var endButtonExists = false
    // A default location to use when location permission is not granted.
    // Coordenadas de la plaza de Bolivar
    let defaultLocation = CLLocation(latitude: 4.5981206, longitude: -74.0782322)
    
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        // Clear the map
        mapView.clear()
        
        // Add a marker to the map
        if selectedPlace != nil {
            let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
        }
        listLikelyPlaces()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.indoorPicker = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        //let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 100.0, right: 0.0)
        //mapView.padding = mapInsets
        
         // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        listLikelyPlaces()
    }
    
    // Function to handle clicks onn points of interest
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
        infoMarker.snippet = placeID
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0;
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
    
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
      // Clean up from previous sessions.
      likelyPlaces.removeAll()

      placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
        if let error = error {
          // TODO: Handle the error.
          print("Current Place error: \(error.localizedDescription)")
          return
        }

        // Get likely places and add to the list.
        if let likelihoodList = placeLikelihoods {
          for likelihood in likelihoodList.likelihoods {
            let place = likelihood.place
            self.likelyPlaces.append(place)
          }
        }
      })
    }
    
    func createMarker(titleMarker: String ,lat: CLLocationDegrees, lng: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lat, lng)
        marker.title = titleMarker
        marker.map = mapView
    }
    
    // MARK: -Navigation
    // Prepare the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "mapToPlaces" {
        if let nextViewController = segue.destination as? PlacesViewController {
          nextViewController.likelyPlaces = likelyPlaces
        }
      }
        if segue.identifier == "mapToRoutes" {
          if let nextViewController = segue.destination as? RoutesTableViewController {
            nextViewController.currentLocation = currentLocation
            nextViewController.places = likelyPlaces
          }
        }
    }
    
    @IBAction func unwindToMapWithRoute(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? PlanViewController, let plan = sourceViewController.plan {
            mapView.clear()
            let zoomCamera = GMSCameraUpdate.zoom(to: 18.0)
            mapView.animate(with: zoomCamera)
            let points = plan.points?.allObjects as! [Point]
            for point in points {
                //let routeOverviewPolyline = route["overview_polyline"].dictionary
                //let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: point.point!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.purple
                polyline.map = self.mapView
            }
            let places = plan.places?.allObjects as! [Place]
            for p in places {
                createMarker(titleMarker: p.name!, lat: p.latitude, lng: p.longitude)
            }
            if !endButtonExists {
                let floatingButton = UIButton(type: .custom)
                let x = 60 as CGFloat
                floatingButton.frame = CGRect(x: mapView.bounds.width - x*1.5 - 50, y: mapView.bounds.height - 25 - x*1.5, width: x, height: x)
                floatingButton.setTitle("End", for: .normal)
                floatingButton.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                floatingButton.clipsToBounds = true
                floatingButton.layer.cornerRadius = x/2
                floatingButton.layer.shadowColor = UIColor.darkGray.cgColor
                floatingButton.layer.shadowPath = CAShapeLayer().path
                floatingButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
                floatingButton.layer.shadowOpacity = 0.8
                floatingButton.layer.shadowRadius = 10
                //floatingButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                //floatingButton.layer.borderWidth = 3.0
                floatingButton.addTarget(self,action: #selector(floatingButtonTapped), for: .touchUpInside)
                view.addSubview(floatingButton)
                endButtonExists = true
            }
            /*motionManager.startDeviceMotionUpdates()
            if motionManager.isGyroAvailable {
                motionManager.startGyroUpdates(to: OperationQueue.main, withHandler: {(gyroData: CMGyroData?, error: Error?) in
                    let y = (gyroData?.rotationRate.y)!

                    let motion = self.motionManager.deviceMotion

                    if(motion?.attitude.pitch != nil) {
                        // rotation calculation (left / right)
                        print("bearing: \(y)")
                        self.mapView.animate(toBearing: y * 180 / .pi )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001, execute: {
                            self.mapView.animate(toBearing: y * 180 / .pi )
                        })
                    }
                })
            }*/
        }
    }
    
    @objc func floatingButtonTapped(sender: UIButton!) {
        endButtonExists = false
        mapView.clear()
        let zoomCamera = GMSCameraUpdate.zoom(to: zoomLevel)
        mapView.animate(with: zoomCamera)
        sender.removeFromSuperview()
    }
}

// MARK: Extensions
// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      let location: CLLocation = locations.last!
        currentLocation = location
        print("Location: \(location)")

      let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude,
                                            zoom: zoomLevel)

      if mapView.isHidden {
        mapView.isHidden = false
        mapView.camera = camera
      } else {
        mapView.animate(to: camera)
      }

      listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      switch status {
      case .restricted:
        print("Location access was restricted.")
      case .denied:
        print("User denied access to location.")
        // Display the map using the default location.
        mapView.isHidden = false
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
