//
//  ListTablesViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 8/3/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit
import CoreData

class ListTablesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topNavigation: UINavigationItem!
    
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    
//    var fetchedResultsController: NSFetchedResultsController<Table>!
    var dataSource: ListTablesTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editDoneTapped(_:)))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editDoneTapped(_:)))
        
        topNavigation.leftBarButtonItem = editButton
        
        dataSource = ListTablesTableViewDataSource(assignedTo: tableView, in: self)
        
//        let fetchRequest: NSFetchRequest<Table> = Table.fetchRequest()
//        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.context, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController.delegate = self
//
//        do {
//            try fetchedResultsController.performFetch()
//        }
//        catch {
//            fatalError("Error!")
//        }
//
//        tableView.reloadData()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let nameAlert = UIAlertController(title: "New Table", message: "Enter name for new table:", preferredStyle: .alert)
        nameAlert.addTextField(configurationHandler: nil)
        nameAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(_) in
            let name = nameAlert.textFields![0].text
            if var nameExisting = name {
                nameExisting = nameExisting.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if (nameExisting != "") {
                    let newTable = Table(context: CoreDataService.context)
                    newTable.name = nameExisting
                    newTable.id = UUID()
                    CoreDataService.saveContext()
                    let tableViewContoller = self.storyboard?.instantiateViewController(withIdentifier: "InventoryTableViewController") as? InventoryTableViewController
                    tableViewContoller!.table = newTable
                    self.navigationController?.pushViewController(tableViewContoller!, animated: true)
                }
            }
        }))
        
        nameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(nameAlert, animated: true)
    }
    
    @objc func editDoneTapped(_ sender: UIBarButtonItem) {
        if sender === editButton {
            tableView.setEditing(true, animated: true)
            topNavigation.leftBarButtonItem = doneButton
        }
        else if sender === doneButton {
            tableView.setEditing(false, animated: true)
            topNavigation.leftBarButtonItem = editButton
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewTableSegue" {
            guard let destination = segue.destination as? InventoryTableViewController else {
                return
            }
            guard let selectedRow = tableView.indexPathForSelectedRow else {
                return
            }
            
            let table = dataSource.fetchedResultsController.object(at: selectedRow)
            tableView.deselectRow(at: selectedRow, animated: true)
            destination.table = table
        }
    }

}

//extension ListTablesViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return fetchedResultsController.fetchedObjects?.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//
//        // Configure the cell...
//        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).name
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let confirmationAlert = UIAlertController(title: "Confirm Delete", message: "This will delete ALL DATA in this table. This cannot be undone. Are you sure you want to delete?", preferredStyle: .alert)
//
//            confirmationAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {(_) in
//                let selectedTable = self.fetchedResultsController.object(at: indexPath)
//                let fetchRequest: NSFetchRequest<CDItem> = CDItem.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "%K == %@", "tableID", selectedTable.id as CVarArg)
//
//                do {
//                    let itemsInTable = try CoreDataService.context.fetch(fetchRequest)
//
//                    for item in itemsInTable {
//                        // delete item
//                        CoreDataService.context.delete(item)
//                    }
//
//                    // delete table itself
//                    CoreDataService.context.delete(selectedTable)
//                    CoreDataService.saveContext()
//                }
//                catch {
//                    let errorAlert = UIAlertController(title: "Error", message: "An error occurred while deleting the data.", preferredStyle: .alert)
//                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(errorAlert, animated: true, completion: nil)
//                }
//
//                self.editDoneTapped(self.doneButton)
//            }))
//
//            confirmationAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(_) in
//                self.editDoneTapped(self.doneButton)
//            }))
//
//            present(confirmationAlert, animated: true, completion: nil)
//        }
//    }
//}

//extension ListTablesViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            guard let insertIndexPath = newIndexPath else {
//                break
//            }
//            tableView.insertRows(at: [insertIndexPath], with: .automatic)
//
//        case .delete:
//            guard let deleteIndexPath = indexPath else {
//                break
//            }
//            tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
//            break
//
//        case .move:
//            guard let beforeIndexPath = indexPath else {
//                break
//            }
//            guard let afterIndexPath = newIndexPath else {
//                break
//            }
//            tableView.moveRow(at: beforeIndexPath, to: afterIndexPath)
//            tableView.endUpdates()
//            tableView.beginUpdates()
//            fallthrough
//
//        case .update:
//            guard let updateIndexPath = newIndexPath else {
//                break
//            }
//            tableView.reloadRows(at: [updateIndexPath], with: .automatic)
//            break
//
//        default:
//            break
//        }
//    }
//}
