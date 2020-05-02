//
//  PlannedRoute+CoreDataProperties.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 25/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//
//

import Foundation
import CoreData


extension PlannedRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlannedRoute> {
        return NSFetchRequest<PlannedRoute>(entityName: "PlannedRoute")
    }

    @NSManaged public var planName: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var points: NSSet?
    @NSManaged public var places: NSSet?

}

// MARK: Generated accessors for points
extension PlannedRoute {

    @objc(addPointsObject:)
    @NSManaged public func addToPoints(_ value: Point)

    @objc(removePointsObject:)
    @NSManaged public func removeFromPoints(_ value: Point)

    @objc(addPoints:)
    @NSManaged public func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged public func removeFromPoints(_ values: NSSet)

}

// MARK: Generated accessors for places
extension PlannedRoute {

    @objc(addPlacesObject:)
    @NSManaged public func addToPlaces(_ value: Place)

    @objc(removePlacesObject:)
    @NSManaged public func removeFromPlaces(_ value: Place)

    @objc(addPlaces:)
    @NSManaged public func addToPlaces(_ values: NSSet)

    @objc(removePlaces:)
    @NSManaged public func removeFromPlaces(_ values: NSSet)

}
