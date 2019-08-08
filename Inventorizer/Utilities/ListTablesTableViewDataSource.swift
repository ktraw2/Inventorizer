//
//  ListTablesTableViewDataSource.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 8/4/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ListTablesTableViewDataSource: NSObject, UITableViewDataSource {
    var tableView: UITableView
    var fetchedResultsController: NSFetchedResultsController<Table>
    var parentViewController: UIViewController
    
    init (assignedTo tableView: UITableView, in parentViewController: UIViewController, filteredBy predicate: NSPredicate? = nil) {
        self.tableView = tableView
        self.parentViewController = parentViewController
        
        let fetchRequest: NSFetchRequest<Table> = Table.fetchRequest()
        fetchRequest.predicate = predicate
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.context, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Error!")
        }
        
        
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let confirmationAlert = UIAlertController(title: "Confirm Delete", message: "This will delete ALL DATA in this table. This cannot be undone. Are you sure you want to delete?", preferredStyle: .alert)
            
            confirmationAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {(_) in
                let selectedTable = self.fetchedResultsController.object(at: indexPath)
                let fetchRequest: NSFetchRequest<CDItem> = CDItem.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "%K == %@", "tableID", selectedTable.id as CVarArg)
                
                do {
                    let itemsInTable = try CoreDataService.context.fetch(fetchRequest)
                    
                    for item in itemsInTable {
                        // delete item
                        CoreDataService.context.delete(item)
                    }
                    
                    // delete table itself
                    CoreDataService.context.delete(selectedTable)
                    CoreDataService.saveContext()
                }
                catch {
                    let errorAlert = UIAlertController(title: "Error", message: "An error occurred while deleting the data.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.parentViewController.present(errorAlert, animated: true, completion: nil)
                }
                
                self.turnOffEdit()
            }))
            
            confirmationAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(_) in
                self.turnOffEdit()
            }))
            
            parentViewController.present(confirmationAlert, animated: true, completion: nil)
        }
    }
    
    func turnOffEdit() {
        if let listTablesVC = parentViewController as? ListTablesViewController {
            listTablesVC.editDoneTapped(listTablesVC.doneButton)
        }
    }
}

extension ListTablesTableViewDataSource: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let insertIndexPath = newIndexPath else {
                break
            }
            tableView.insertRows(at: [insertIndexPath], with: .automatic)
            
        case .delete:
            guard let deleteIndexPath = indexPath else {
                break
            }
            tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
            break
            
        case .move:
            guard let beforeIndexPath = indexPath else {
                break
            }
            guard let afterIndexPath = newIndexPath else {
                break
            }
            tableView.moveRow(at: beforeIndexPath, to: afterIndexPath)
            tableView.endUpdates()
            tableView.beginUpdates()
            fallthrough
            
        case .update:
            guard let updateIndexPath = newIndexPath else {
                break
            }
            tableView.reloadRows(at: [updateIndexPath], with: .automatic)
            break
            
        default:
            break
        }
    }
}
