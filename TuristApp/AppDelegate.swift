//
//  AppDelegate.swift
//  TuristApp
//
//  Created by Diana Cepeda on 27/02/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import Firebase
import CoreData
import Network

@UIApplicationMain
  class AppDelegate: UIResponder, UIApplicationDelegate, NSFetchedResultsControllerDelegate {

    var window: UIWindow?
    
    var db: Firestore?
    
    let monitor = NWPathMonitor()
    var connected: Bool?
    
    private var planFetch: NSFetchedResultsController<PlannedRoute>!
    private var placesFetch: NSFetchedResultsController<Place>!
    private var typesFethc: NSFetchedResultsController<Type>!
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataMap")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            print(storeDescription)
      
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            UserDefaults.standard.set(true, forKey: "firebaseSyncPending")
            do {
                try context.save()
            } catch {
                let err = error as NSError
                fatalError("Unresolved error \(err), \(err.userInfo)")
            }
            if connected! {
                DispatchQueue.global(qos: .background).async {
                    self.syncFirebase(db: self.db!)
                }
            }
        }
    }
    
    func syncFirebase(db: Firestore) {
        let context = persistentContainer.viewContext
        let planRequest = PlannedRoute.fetchRequest() as NSFetchRequest<PlannedRoute>
        let sort = NSSortDescriptor(key: #keyPath(PlannedRoute.createdAt), ascending: true)
        planRequest.sortDescriptors = [sort]
        
        var plans: [PlannedRoute] = []
        do {
            plans = try context.fetch(planRequest)
        } catch let error as NSError {
            print("Could not fetch plans. \(error), \(error.userInfo)")
        }
        
        for plan in plans {
            let placeRequest = Place.fetchRequest() as NSFetchRequest<Place>
            placeRequest.predicate = NSPredicate(format: "plan.planName == %@", plan.planName! as NSString)
            
            var places: [Place] = []
            var placesToSave: [[String:Any]] = [[:]]
            
            do {
                places = try context.fetch(placeRequest)
            } catch let error as NSError {
                print("Could not fetch places. \(error), \(error.userInfo)")
            }
            
            for place in places {
                var placeToSave: [String:Any] = [:]
                let typeRequest = Type.fetchRequest() as NSFetchRequest<Type>
                typeRequest.predicate = NSPredicate(format: "place.name == %@", place.name! as NSString)
                
                var types: [Type] = []
                var typesToSave: [String] = []
                
                do {
                    types = try context.fetch(typeRequest)
                } catch let error as NSError {
                    print("Could not fetch types. \(error), \(error.userInfo)")
                }
                
                for type in types {
                    typesToSave.append(type.type!)
                }
                
                placeToSave["formattedAddress"] = place.formattedAddress!
                placeToSave["name"] = place.name!
                placeToSave["placeId"] = place.placeId ?? ""
                placeToSave["types"] = typesToSave
                placesToSave.append(placeToSave)
                
                Analytics.logEvent("places_visited", parameters: ["name": place.name!, "date": Timestamp(date: plan.createdAt!)])
            }
            
            let planToSave: [String:Any] = [
                "planName": plan.planName!,
                "createdAt": Timestamp(date: plan.createdAt!),
                "places": placesToSave
            ]
            db.collection("plans").document(plan.planName!).setData(planToSave) {err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    UserDefaults.standard.set(false, forKey: "firebaseSyncPending")
                     print("Document successfully written!")
                }
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        guard let key = ProcessInfo.processInfo.environment["GOOGLE_MAPS_KEY"] else {
            fatalError("Problems with Google Maps API Key")
        }
        GMSServices.provideAPIKey(key)
        GMSPlacesClient.provideAPIKey(key)
        
        FirebaseApp.configure()
        db = Firestore.firestore()
                
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
        }
        catch {
            switch error as? Network.Error {
            case let .failedToCreateWith(hostname)?:
                print("Network error:\nFailed to create reachability object With host named:", hostname)
            case let .failedToInitializeWith(address)?:
                print("Network error:\nFailed to initialize reachability object With address:", address)
            case .failedToSetCallout?:
                print("Network error:\nFailed to set callout")
            case .failedToSetDispatchQueue?:
                print("Network error:\nFailed to set DispatchQueue")
            case .none:
                print(error)
            }
        }
        
        monitor.pathUpdateHandler = {path in
            let updateNeeded = UserDefaults.standard.bool(forKey: "firebaseSyncPending")
            print("Monitor set up")
            if path.status == .satisfied {
                self.connected = true
                if updateNeeded {
                    self.syncFirebase(db: self.db!)
                }
            } else {
                self.connected = false
            }
        }
        let queue = DispatchQueue(label: "FirebaseMonitor")
        monitor.start(queue: queue)
        
        Analytics.logEvent("last_open", parameters: ["date": Timestamp(date: Date())])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

