//
//  CoreDataManager.swift
//  GitHubTest
//
//  Created by Roman Syrota on 31.03.2018.
//  Copyright © 2018 Roman Syrota. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    static let shared = CoreDataManager()
    
    //MARK: - Core Data Stack
    var applicationDocumentsDirectory: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }
    
    var managedObjectModel: NSManagedObjectModel {
        let modelURL = Bundle(for: CoreDataManager.self).url(forResource: "GitHubTest", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("GitHubTest.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(value: true as Bool), NSInferMappingModelAutomaticallyOption: NSNumber(value: true as Bool)]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return coordinator
    }
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let coordinator = persistentStoreCoordinator
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainManagedObjectContext
        return context
    }()
    
    //MARK: - Help Methods
    func entityFor(name: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: name, in: privateManagedObjectContext)!
    }
    
    func fetchedResultController(entityName: String, keyForSort: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: keyForSort, ascending: false)]
        let fetchedResultController =
            NSFetchedResultsController(fetchRequest: fetchRequest,
                                       managedObjectContext: mainManagedObjectContext,
                                       sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    //MARK: - Core Data Save Support
    func saveContext () {
        if mainManagedObjectContext.hasChanges {
            do {
                try mainManagedObjectContext.save()
            } catch let nserror as NSError {
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
