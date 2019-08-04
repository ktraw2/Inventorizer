//
//  ListTablesTableViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/23/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit
import CoreData

class ListTablesTableViewController: UITableViewController {

    var fetchedResultsController: NSFetchedResultsController<Table>!
    
//    override func loadView() {
//        
//        
//        super.loadView()
//        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
//        print(tableView.constraints)
//        print(self.view.constraints)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let fetchRequest: NSFetchRequest<Table> = Table.fetchRequest()
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Error!")
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    @IBAction func editTapped(_ sender: Any) {
        
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewTableSegue" {
            guard let destination = segue.destination as? InventoryTableViewController else {
                return
            }
            guard let selectedRow = tableView.indexPathForSelectedRow else {
                return
            }
            
            let table = fetchedResultsController.object(at: selectedRow)
            tableView.deselectRow(at: selectedRow, animated: true)
            destination.table = table
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ListTablesTableViewController: NSFetchedResultsControllerDelegate {
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
