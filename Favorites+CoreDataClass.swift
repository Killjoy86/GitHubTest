//
//  Favorites+CoreDataClass.swift
//  
//
//  Created by Roman Syrota on 02.04.2018.
//
//

import Foundation
import CoreData

@objc(Favorites)
public class Favorites: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.shared.entityFor(name: "Favorites"),
                  insertInto: CoreDataManager.shared.privateManagedObjectContext)
    }
}
