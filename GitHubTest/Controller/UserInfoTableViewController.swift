//
//  SearchTableViewController.swift
//  GitHubTest
//
//  Created by Roman Syrota on 31.03.2018.
//  Copyright © 2018 Roman Syrota. All rights reserved.
//

import UIKit
import CoreData

class UserInfoTableViewController: UITableViewController {
    
    var searchController : UISearchController!
    var user: User!
    
    func fetchRequestBy(identifier: Int) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        let predicate = NSPredicate(format: "%K == %@", "identifier", String(identifier))
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        return fetchRequest
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        tableView.allowsSelection = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData(_:)), name: .NSPersistentStoreCoordinatorStoresDidChange, object: nil)
    }
    
    //MARK: - Notification's selectors 
    @objc func updateData(_ notification: NSNotification) {
        self.tableView.reloadData()
    }
    
    //MARK: - Title setting support
    private func setUpTitle() {
        var titleName = ""
        if let name = user.name {
            titleName = name + "/"
        }
        if let login = user.login {
            titleName += login
        }
        self.title = titleName
    }
    
}

// MARK: - Table view data source
extension UserInfoTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.reposArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
        cell.delegate = self
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    //MARK: - Cells configuration
    
    private func configure(_ cell: SearchTableViewCell, at indexPath: IndexPath) {
        let repo = user.reposArray![indexPath.row]

        let fetchRequest = fetchRequestBy(identifier: repo.identifier)
        do {
            let fetchedObjects = try CoreDataManager.shared.mainManagedObjectContext.fetch(fetchRequest) as! [Favorites]
            
            if fetchedObjects.count > 0 {
                let object = fetchedObjects.first!
                
                if object.identifier == repo.identifier {
                    cell.favotiteButton.setImage(UIImage(named: "Favorites.png"), for: .normal)
                    cell.isFavorite = true
                }
            } else {
                cell.favotiteButton.setImage(UIImage(named: "notFavorites.png"), for: .normal)
                cell.isFavorite = false
            }
            
        } catch {
            
        }
        cell.repository = repo
        cell.repoNameLabel.text = repo.name
        cell.repoStarsLabel.text = String(repo.stargazers)
        
    }
}


//MARK: - SearchTableViewCellDelegate
extension UserInfoTableViewController: SearchTableViewCellDelegate {
    func addObjectToFavorites(repository: Repository) {
        CoreDataManager.shared.privateManagedObjectContext.perform {
            let favorites = Favorites()
            favorites.identifier = Int32(repository.identifier)
            favorites.name = repository.name
            favorites.stars = Int32(repository.stargazers)
            
            do {
                try CoreDataManager.shared.privateManagedObjectContext.save()
                
                CoreDataManager.shared.mainManagedObjectContext.performAndWait {
                    do {
                        try CoreDataManager.shared.mainManagedObjectContext.save()
                    } catch let error as NSError {
                        print("Failure to save context: \(error.localizedDescription)")
                    }
                }
            } catch let error as NSError {
                print("Failure to save context: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteObjectFromFavorites(repository: Repository) {
        CoreDataManager.shared.privateManagedObjectContext.perform {
            let fetchRequest = self.fetchRequestBy(identifier: repository.identifier)
            do {
                let fetchResult = try CoreDataManager.shared.privateManagedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
                
                if !fetchResult.isEmpty {
                    let managedObject = fetchResult.first!
                    CoreDataManager.shared.privateManagedObjectContext.delete(managedObject)
                    do {
                        try CoreDataManager.shared.privateManagedObjectContext.save()
                        
                        CoreDataManager.shared.mainManagedObjectContext.performAndWait {
                            do {
                                try CoreDataManager.shared.mainManagedObjectContext.save()
                            } catch let error as NSError {
                                print("Failure to save context: \(error.localizedDescription)")
                            }
                        }
                    } catch let error as NSError {
                        print("Failure to save context: \(error.localizedDescription)")
                    }
                }
            } catch let error as NSError {
                print("Failure to fetch data: \(error.localizedDescription)")
            }
            
        }
    }
}

