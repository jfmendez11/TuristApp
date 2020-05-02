//
//  Plan.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 13/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//

import Foundation
import os.log
import UIKit
import GooglePlaces
import SwiftyJSON

class Plan {
    // MARK: Properties
    var pointsOfInterest = [GMSPlace]()
    var name: String
    var createdAt: Date
    var routes: [JSON] = []
    
    // MARK: Missing: Archiving Paths
    
    // MARK: Types
    struct propKey {
        static let pointsOfInterest = "pointsOfInterest"
        static let name = "name"
        static let createdAt = "createdAt"
    }
    
    // MARK: Initialization
    init?(name: String, createdAt: Date) {
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
        self.createdAt = createdAt
    }
    
   // MARK: - Fucntions
    func setRoutes(routes: [JSON]) {
        self.routes = routes
    }
}
