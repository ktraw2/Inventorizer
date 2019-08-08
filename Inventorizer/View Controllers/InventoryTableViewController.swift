//
//  ViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/3/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit

class InventoryTableViewController: UIViewController {
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var topNavigation: UINavigationItem!
    @IBOutlet var moveButton: UIBarButtonItem!
    
    var buttonsNotEditing: [UIBarButtonItem]!
    var buttonsEditing: [UIBarButtonItem]!
    var searchController: UISearchController!
    var dataSource: InventorizerTableViewDataSource!
    
    var table: Table!
    var numTables = 1
    
    let trashButton: UIBarButtonItem = { () -> UIBarButtonItem in
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: #selector(trashTapped(_:)))
        
        // disable trash and mark buttons by defualt
        trashButton.isEnabled = false
        trashButton.tintColor = UIColor.red
        return trashButton
    }()
    
    let markButton = UIBarButtonItem(title: "Mark", style: .plain, target: nil, action: #selector(markTapped(_:)))
    
    var searchScope = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        // initialize the data source and set the table's data source to it
        dataSource = InventorizerTableViewDataSource(assignedTo: mainTable, for: table)
        
        // make the button bar for when no editing is happening
        buttonsNotEditing = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: #selector(editToogleTapped(_:)))]
        
        // make the button bar for when editing is happening
        buttonsEditing = [trashButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), moveButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), markButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(editToogleTapped(_:)))]
        
        // set the toolbar to have the not editing bar
        bottomToolBar.setItems(buttonsNotEditing, animated: false)

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All", "Accounted For", "Not Accounted For"]
        searchController.searchBar.delegate = self
        
        if #available(iOS 11.0, *) {
            topNavigation.searchController = searchController
            topNavigation.hidesSearchBarWhenScrolling = false
        }
        else {
            mainTable.tableHeaderView = searchController.searchBar
        }
        
        definesPresentationContext = true
        
        topNavigation.title = table.name
    }
    
    @objc func trashTapped(_ sender: UIBarButtonItem) {
        guard let numRowsSelected = mainTable.indexPathsForSelectedRows?.count else {
            return
        }
        guard var indexPaths = mainTable.indexPathsForSelectedRows else {
            return
        }
        
        let confirmDelete = UIAlertController(title: "Delete \(numRowsSelected) row\((numRowsSelected == 1) ? "" : "s")?", message: nil, preferredStyle: .actionSheet)
        
        // code for iPads
        confirmDelete.popoverPresentationController?.barButtonItem = sender
        
        confirmDelete.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            // delete rows of table
            indexPaths.sort()
            var currentSection = 0
            var shiftRow = 0
            var shiftSection = 0
            
            for indexPath in indexPaths {
                if indexPath.section > currentSection {
                    shiftRow = 0
                    
                    if self.dataSource.sectionWasRemoved {
                        shiftSection += 1
                        self.dataSource.sectionWasRemoved = false
                    }
                    currentSection = indexPath.section
                }
                
                self.dataSource.tableView(self.mainTable, commit: .delete, forRowAt: IndexPath(row: indexPath.row - shiftRow, section: indexPath.section - shiftSection))
                shiftRow += 1
            }
            
            if self.dataSource.sectionWasRemoved {
                self.dataSource.sectionWasRemoved = false
            }
            
            self.mainTable.reloadSectionIndexTitles()
            
            self.editToogleTapped(sender)
        }))
        
        confirmDelete.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(confirmDelete, animated: true)
    }
    
    @objc func markTapped(_ sender: UIBarButtonItem) {
        var numRowsSelected = 0
        if sender.title != "Mark All", let unwrapNumRowsSelected = mainTable.indexPathsForSelectedRows?.count {
            numRowsSelected = unwrapNumRowsSelected
        }
        else if sender.title != "Mark All" {
            return
        }
        

        let rows = (numRowsSelected == 0) ? (dataSource.fetchedResultsController.fetchedObjects?.count ?? 0) : numRowsSelected
        
        let markOptions = UIAlertController(title: "Mark \((numRowsSelected == 0 && rows != 1) ? "all \(rows)" : "\(rows)") row\((rows == 1) ? "" : "s")", message: nil, preferredStyle: .actionSheet)
        
        // code for iPads
        markOptions.popoverPresentationController?.barButtonItem = sender
        
        markOptions.addAction(UIAlertAction(title: "Accounted For", style: .default, handler: {(_) in
            if numRowsSelected != 0 {
                self.markSelected(as: true, for: sender)
            }
            else {
                self.markAll(as: true, for: sender)
            }
        }))
        
        markOptions.addAction(UIAlertAction(title: "Not Accounted For", style: .default, handler: {(_) in
            if numRowsSelected != 0 {
                self.markSelected(as: false, for: sender)
            }
            else {
                self.markAll(as: false, for: sender)
            }
        }))
        
        markOptions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(markOptions, animated: true)
    }
    
    func markSelected(as value: Bool, for sender: UIBarButtonItem) {
        guard let indexPaths = mainTable.indexPathsForSelectedRows else {
            return
        }
        
        
        // code to mark all
        for indexPath in indexPaths {
            let item = dataSource.fetchedResultsController.object(at: indexPath)
            
            item.accountedFor = value
        }
        dataSource.saveData()
        
        // disable editing
        // TODO: determine if I want this behavior, could make it a setting
        editToogleTapped(sender)
    }
    
    func markAll(as value: Bool, for sender: UIBarButtonItem) {
        guard let objects = dataSource.fetchedResultsController.fetchedObjects else {
            return
        }
        
        for item in objects {
            item.accountedFor = value
        }
        
        dataSource.saveData()
        
        editToogleTapped(sender)
    }
    
    @objc func moveTapped(_ sender: Any) {
        guard let moveViewController = storyboard?.instantiateViewController(withIdentifier: "MoveTableViewController") as? UITableViewController else {
            return
        }
        
        moveViewController.tableView.dataSource = nil
        let exclusionPredicate = NSPredicate(format: "%K != %@", "id", table.id as CVarArg)
        let dataSourceExcludingSelf = ListTablesTableViewDataSource(assignedTo: moveViewController.tableView, in: moveViewController, filteredBy: exclusionPredicate)
        
        let numTables = dataSourceExcludingSelf.fetchedResultsController.fetchedObjects?.count ?? 0
        if numTables != 0 {
            let numRows = mainTable.indexPathsForSelectedRows?.count ?? 0
            moveViewController.navigationItem.prompt = "Move \(numRows) items"
            navigationController?.pushViewController(moveViewController, animated: true)
        }
        else {
            let errorAlert = UIAlertController(title: "Error", message: "You do not have any other tables. Please create a new table before moving an item.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(errorAlert, animated: true, completion: nil)
        }
    }
    
    @objc func editToogleTapped(_ sender: Any) {
        if mainTable.isEditing {
            bottomToolBar.setItems(buttonsNotEditing, animated: true)
            mainTable.setEditing(false, animated: true)
        }
        else {
            trashButton.isEnabled = false
            moveButton.isEnabled = false
            enableDisableMarkButton()
            markButton.title = "Mark All"
            bottomToolBar.setItems(buttonsEditing, animated: true)
            mainTable.setEditing(true, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditItemSegue", let indexPath = mainTable.indexPathForSelectedRow {
            // only continue if we are going to InventoryItemViewController
            guard let item = segue.destination as? InventoryItemViewController else {
                return
            }
            let selectedItem = dataSource.fetchedResultsController.object(at: indexPath)
            
            item.incomingItem = selectedItem
            item.masterDataSource = dataSource
            mainTable.deselectRow(at: indexPath, animated: false)
        }
        else if segue.identifier == "NewItemSegue" {
            guard let nav = segue.destination as? UINavigationController else {
                return
            }
            guard let item = nav.topViewController as? InventoryItemViewController else {
                return
            }
            
            item.masterDataSource = dataSource
        }
        else if segue.identifier == "ViewOptionsSegue" {
            guard let destination = segue.destination as? OptionsViewController else {
                return
            }
            
            destination.table = table
            destination.parentTableVC = self
        }
        else if segue.identifier == "MoveItemsSegue" {
            guard let destination = segue.destination as? SelectTableViewController else {
                return
            }
            
            destination.originatingTable = table
            destination.numRows = mainTable.indexPathsForSelectedRows?.count ?? 0
        }
    }
    
    func enableDisableMarkButton() {
        if dataSource.fetchedResultsController.fetchedObjects?.count ?? 0 == 0 {
            markButton.isEnabled = false
        }
        else {
            markButton.isEnabled = true
        }
    }
    
    // MARK: Begin Unwind funcs
    
    @IBAction func didUnwindFromOptions (_ sender: UIStoryboardSegue) {
        topNavigation.title = table.name
    }
    
    @IBAction func didUnwindSaveFromItem (_ sender: UIStoryboardSegue) {
        enableDisableMarkButton()
    }
    
    @IBAction func didUnwindCancelMove(_ sender: UIStoryboardSegue) {
    
    }
    
    @IBAction func didUnwindConfirmMove(_ sender: UIStoryboardSegue) {
        guard let origin = sender.source as? SelectTableViewController else {
            return
        }
        guard let selectedTable = origin.tableView.indexPathForSelectedRow else {
            return
        }
        guard let selectedRows = mainTable.indexPathsForSelectedRows else {
            return
        }
        
        let newTable = origin.dataSource.fetchedResultsController.object(at: selectedTable)
        for row in selectedRows {
            dataSource.fetchedResultsController.object(at: row).tableID = newTable.id
        }
        
        CoreDataService.saveContext()
        editToogleTapped(self)
    }
    
    // MARK: End Unwind funcs    
}

// MARK: UITableViewDelegate extension
extension InventoryTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        // only if in normal mode
        if tableView.isEditing == false {
            performSegue(withIdentifier: "EditItemSegue", sender: self)
        }
        else {
            // sanity check
            if (tableView.indexPathsForSelectedRows?.count ?? 0) > 0 {
                trashButton.isEnabled = true
                moveButton.isEnabled = (numTables > 1)
                markButton.title = "Mark"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if (tableView.indexPathsForSelectedRows?.count ?? 0) < 1 {
                trashButton.isEnabled = false
                moveButton.isEnabled = false
                markButton.title = "Mark All"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }
}

extension InventoryTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        var optionalScopeModifier: NSPredicate?
        if searchScope == 1 {
            optionalScopeModifier = NSPredicate(format: "accountedFor == true")
        }
        else if searchScope == 2 {
            optionalScopeModifier = NSPredicate(format: "accountedFor == false")
        }
        
        // display nothing if no query is entered
        if searchQuery == "" {
            dataSource.reloadData(using: optionalScopeModifier)
            enableDisableMarkButton()
            return
        }
        
        let tokenizedQuery = searchQuery.components(separatedBy: " ")
        var predicateArray = [NSPredicate]()
        
        for query in tokenizedQuery {
            let subpredicate = NSPredicate(format: "(name CONTAINS[c] %@) OR (categoryName CONTAINS[c] %@) OR (categoryName == '' AND 'No Category' CONTAINS[c] %@)", query, query, query)
            predicateArray.append(subpredicate)
        }
        
        predicateArray.appendOptional(optionalScopeModifier)

        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        
        dataSource.reloadData(using: compoundPredicate)
        enableDisableMarkButton()
    }
}

extension InventoryTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchScope = selectedScope
        updateSearchResults(for: searchController)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.selectedScopeButtonIndex = 0
        searchScope = 0
        markButton.isEnabled = true
    }
}
