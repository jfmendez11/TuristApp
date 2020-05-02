//
//  Type+CoreDataProperties.swift
//  TuristApp
//
//  Created by Juan Felipe Méndez on 25/04/20.
//  Copyright © 2020 Diana Cepeda. All rights reserved.
//
//

import Foundation
import CoreData


extension Type {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Type> {
        return NSFetchRequest<Type>(entityName: "Type")
    }

    @NSManaged public var type: String?
    @NSManaged public var place: Place?

}
