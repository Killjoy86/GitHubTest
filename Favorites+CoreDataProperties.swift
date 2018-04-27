//
//  Favorites+CoreDataProperties.swift
//  
//
//  Created by Roman Syrota on 02.04.2018.
//
//

import Foundation
import CoreData


extension Favorites {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorites> {
        return NSFetchRequest<Favorites>(entityName: "Favorites")
    }

    @NSManaged public var name: String?
    @NSManaged public var stars: Int32
    @NSManaged public var identifier: Int32

}
