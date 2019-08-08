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
    
    var dataSource: ListTablesTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editDoneTapped(_:)))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editDoneTapped(_:)))
        
        topNavigation.leftBarButtonItem = editButton
        
        dataSource = ListTablesTableViewDataSource(assignedTo: tableView, in: self)
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
                    guard let tableViewContoller = self.storyboard?.instantiateViewController(withIdentifier: "InventoryTableViewController") as? InventoryTableViewController else {
                        let errorAlert = UIAlertController(title: "Error", message: "Could not display new table. Please restart the app.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlert, animated: true, completion: nil)
                        return
                    }
                    tableViewContoller.table = newTable
                    tableViewContoller.numTables = self.dataSource.fetchedResultsController.fetchedObjects?.count ?? 0
                    self.navigationController?.pushViewController(tableViewContoller, animated: true)
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
            destination.numTables = dataSource.fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }

}
