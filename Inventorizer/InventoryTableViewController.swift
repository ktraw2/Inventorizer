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
    
    var buttonsNotEditing: [UIBarButtonItem]!
    var buttonsEditing: [UIBarButtonItem]!
    var searchController: UISearchController!
    var dataSource: InventorizerTableViewDataSource!
    
    let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: #selector(trashTapped(_:)))
    let markButton = UIBarButtonItem(title: "Mark", style: .plain, target: nil, action: #selector(markTapped(_:)))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        // initialize the data source and set the table's data source to it
        dataSource = InventorizerTableViewDataSource()
        mainTable.dataSource = dataSource
        
        // make the button bar for when no editing is happening
        buttonsNotEditing = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: #selector(editToogleTapped(_:)))]
        
        // make the button bar for when editing is happening
        // disable trash and mark buttons by defualt
        trashButton.isEnabled = false
        markButton.isEnabled = false
        
        buttonsEditing = [trashButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), markButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(editToogleTapped(_:)))]
        
        // set the toolbar to have the not editing bar
        bottomToolBar.setItems(buttonsNotEditing, animated: false)
        
        let resultsController = SearchResultsTableViewController(style: .grouped)
        resultsController.baseNavigationController = navigationController
        resultsController.masterDataSource = dataSource
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        
        if #available(iOS 11.0, *) {
            topNavigation.searchController = searchController
            topNavigation.hidesSearchBarWhenScrolling = false
        }
        else {
            mainTable.tableHeaderView = searchController.searchBar
        }
        
        definesPresentationContext = true
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
            var sectionsToUpdate = [Int]()
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
                    else {
                        sectionsToUpdate.append(currentSection - shiftSection)
                    }
                    currentSection = indexPath.section
                }
                
                self.dataSource.tableView(self.mainTable, commit: .delete, forRowAt: IndexPath(row: indexPath.row - shiftRow, section: indexPath.section - shiftSection))
                shiftRow += 1
            }
            
            print(self.dataSource.sectionWasRemoved)
            if self.dataSource.sectionWasRemoved == false {
                sectionsToUpdate.append(currentSection - shiftSection)
            }
            else {
                self.dataSource.sectionWasRemoved = false
            }
            print(sectionsToUpdate)
            if sectionsToUpdate.count > 0 {
                self.mainTable.reloadSectionIndexTitles()
                self.mainTable.reloadSections(IndexSet(sectionsToUpdate), with: .none)
            }
            self.editToogleTapped(sender)
        }))
        
        confirmDelete.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(confirmDelete, animated: true)
    }
    
    @objc func markTapped(_ sender: UIBarButtonItem) {
        guard let numRowsSelected = mainTable.indexPathsForSelectedRows?.count else {
            return
        }
        guard let indexPaths = mainTable.indexPathsForSelectedRows else {
            return
        }
        
        let markOptions = UIAlertController(title: "Mark \(numRowsSelected) row\((numRowsSelected == 1) ? "" : "s")", message: nil, preferredStyle: .actionSheet)
        
        // code for iPads
        markOptions.popoverPresentationController?.barButtonItem = sender
        
        markOptions.addAction(UIAlertAction(title: "Accounted For", style: .default, handler: {(_) in
            // code to mark all
            for indexPath in indexPaths {
                self.dataSource.itemsByCategory[indexPath.section].getItem(at: indexPath.row).accountedFor = true
            }
            
            // disable editing
            // TODO: determine if I want this behavior, could make it a setting
            self.editToogleTapped(sender)
        }))
        
        markOptions.addAction(UIAlertAction(title: "Not Accounted For", style: .default, handler: {(_) in
            // code to unmark all
            for indexPath in indexPaths {
                self.dataSource.itemsByCategory[indexPath.section].getItem(at: indexPath.row).accountedFor = false
            }
            
            // disable editing
            // TODO: determine if I want this behavior, could make it a setting
            self.editToogleTapped(sender)
        }))
        
        markOptions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(markOptions, animated: true)
    }
    
    @objc func editToogleTapped(_ sender: Any) {
        if mainTable.isEditing {
            bottomToolBar.setItems(buttonsNotEditing, animated: true)
            mainTable.setEditing(false, animated: true)
        }
        else {
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
            
            searchController.isActive = false
//            item.incomingItemToEdit = dataSource.itemsByCategory[indexPath.section].getItem(at: indexPath.row)
//            item.incomingItemCategory = dataSource.itemsByCategory[indexPath.section]
//            item.incomingItemCategoryIndex = indexPath.section
            item.incomingData = CategorizedItem(item: dataSource.itemsByCategory[indexPath.section].getItem(at: indexPath.row), indexedCategory: IndexedCategory(category: dataSource.itemsByCategory[indexPath.section], index: indexPath.section))
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
    }
    
    // MARK: Begin Unwind funcs
    
    @IBAction func didUnwindSaveFromItem (_ sender: UIStoryboardSegue) {
        // only continue if we are unwinding from InventoryItemViewController
        guard sender.source is InventoryItemViewController else {
            return
        }
        
        self.mainTable.reloadData()
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
                markButton.isEnabled = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if (tableView.indexPathsForSelectedRows?.count ?? 0) < 1 {
                trashButton.isEnabled = false
                markButton.isEnabled = false
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
        guard let resultsController = searchController.searchResultsController as? SearchResultsTableViewController else {
            return
        }
        
        resultsController.dataSource.itemsByCategory = [Category]()
        
        // display nothing if no query is entered
        if searchQuery == "" {
            resultsController.tableView.reloadData()
            return
        }
        
        let tokenizedQuery = searchQuery.components(separatedBy: " ")
        var predicateArray = [NSPredicate]()
        
        for query in tokenizedQuery {
            let subpredicate = NSPredicate(format: "(name CONTAINS[c] %@) OR (category CONTAINS[c] %@) OR (category == '' AND 'Uncategorized' CONTAINS[c] %@)", query, query, query)
            predicateArray.append(subpredicate)
        }
        
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
        var i = 0
        
        for category in dataSource.itemsByCategory {
            let arrayToFilter = category.getItems() as NSArray
            let results = arrayToFilter.filtered(using: compoundPredicate) as! [InventoryItem]
            
            if results.count > 0 {
                let resultsCategory = Category(name: category.getName(), initialItems: results)
                resultsController.dataSource.itemsByCategory.append(resultsCategory)
                resultsController.resultsToWholeCategoryMap[resultsCategory] = IndexedCategory(category: category, index: i)
            }
            
            i += 1
        }
        
        resultsController.dataSource.itemsByCategory.sort()
        resultsController.tableView.reloadData()
//        let arrayToFiter = dataSource.itemsByCategory as NSArray
//        resultsController.dataSource.itemsByCategory = arrayToFiter.filtered(using: categoryPredicate) as! [Category]
//        resultsController.tableView.reloadData()
    }
}
