//
//  FavoritesTableViewController.swift
//  GitHubTest
//
//  Created by Roman Syrota on 31.03.2018.
//  Copyright © 2018 Roman Syrota. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {

    var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultController = CoreDataManager.shared.fetchedResultController(entityName: "Favorites",
                                                                                 keyForSort: "stars")
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }

}

// MARK: - Table view data source
extension FavoritesTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath) as! FavoritesTableViewCell
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    //MARK: - Cells configurations
    private func configure(_ cell: FavoritesTableViewCell, at indexPath: IndexPath) {
        let favorites = fetchedResultController.object(at: indexPath) as! Favorites
        
        cell.nameLabel.text = favorites.name
        cell.stargazersCountLabel.text = String(favorites.stars)
        
    }
}

// MARK: - Table view delegate
extension FavoritesTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataManager.shared.mainManagedObjectContext.perform {
                let managedObject = self.fetchedResultController.object(at: indexPath) as! NSManagedObject
                CoreDataManager.shared.mainManagedObjectContext.delete(managedObject)
                do {
                    try CoreDataManager.shared.mainManagedObjectContext.save()
                    CoreDataManager.shared.privateManagedObjectContext.performAndWait {
                        do {
                            try CoreDataManager.shared.privateManagedObjectContext.save()
                            NotificationCenter.default.post(name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: nil)
                        } catch let error as NSError {
                            print("Unresolved error \(error), \(error.userInfo)")
                        }
                    }
                } catch let error as NSError {
                    print("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }
    
}


//MARK: - NSFetchedResultsControllerDelegate

extension FavoritesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}







