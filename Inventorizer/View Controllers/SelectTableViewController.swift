//
//  SelectTableViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 8/8/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit

class SelectTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topNavigation: UINavigationItem!
    @IBOutlet weak var moveButton: UIBarButtonItem!
    
    var originatingTable: Table!
    var numRows: Int = 0
    
    var dataSource: ListTablesTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let exclusionPredicate = NSPredicate(format: "%K != %@", "id", originatingTable.id as CVarArg)
        dataSource = ListTablesTableViewDataSource(assignedTo: tableView, in: self, filteredBy: exclusionPredicate)
        
        let numTables = dataSource.fetchedResultsController.fetchedObjects?.count ?? 0
        if numTables != 0 {
            topNavigation.prompt = "Move \(numRows) item\((numRows == 1) ? "" : "s")"
        }
        else {
            let errorAlert = UIAlertController(title: "Error", message: "You do not have any other tables. Please create a new table before moving an item.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in
                self.performSegue(withIdentifier: "CancelUnwindSegue", sender: self)
            }))
            present(errorAlert, animated: true, completion: nil)
        }
    }
}

extension SelectTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moveButton.isEnabled = true
    }
}
