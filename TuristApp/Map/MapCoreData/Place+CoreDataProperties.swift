//
//  Place+CoreDataProperties.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 25/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//
//

import Foundation
import CoreData


extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }

    @NSManaged public var formattedAddress: String?
    @NSManaged public var name: String?
    @NSManaged public var photo: Data?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var phone: String?
    @NSManaged public var rating: Float
    @NSManaged public var website: String?
    @NSManaged public var plan: PlannedRoute?
    @NSManaged public var types: NSSet?
    @NSManaged public var placeId: String?

}

// MARK: Generated accessors for types
extension Place {

    @objc(addTypesObject:)
    @NSManaged public func addToTypes(_ value: Type)

    @objc(removeTypesObject:)
    @NSManaged public func removeFromTypes(_ value: Type)

    @objc(addTypes:)
    @NSManaged public func addToTypes(_ values: NSSet)

    @objc(removeTypes:)
    @NSManaged public func removeFromTypes(_ values: NSSet)

}
