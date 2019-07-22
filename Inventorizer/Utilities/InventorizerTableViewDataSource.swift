//
//  InventorizerTableViewDataSource.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/7/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class InventorizerTableViewDataSource: NSObject, UITableViewDataSource {

    var tableView: UITableView
    var fetchedResultsController: NSFetchedResultsController<CDItem>
    var sectionWasRemoved = false
    
    init(assignedTo tableView: UITableView) {
        let fetchRequest: NSFetchRequest<CDItem> = CDItem.fetchRequest()
        let categorySorting = NSSortDescriptor(key: "categoryName", ascending: true)
        let nameSorting = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [categorySorting, nameSorting]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.context, sectionNameKeyPath: "categoryName", cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Error!")
        }
        
        self.tableView = tableView
        
        super.init()
        fetchedResultsController.delegate = self
        tableView.dataSource = self
    }
    
    func reloadData(using predicate: NSPredicate? = nil) {
        fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Error!")
        }
        
        tableView.reloadData()
    }
    
    func reloadSectionFooter(at sectionIndex: Int) {
        if let footerView = tableView.footerView(forSection: sectionIndex), let textLabel = footerView.textLabel {
            textLabel.text = tableView(tableView, titleForFooterInSection: sectionIndex)
            footerView.sizeToFit()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let item = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func sectionIndexTitles(for: UITableView) -> [String]? {
        var result = [String]()
        guard let sections = fetchedResultsController.sections else {
            return result
        }
        
        for category in sections {
            let name = category.name
            result.append("\((name == "") ? "No Category" : name) (\(category.numberOfObjects))")
        }
        
        return result
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController.sections else {
            return "ERROR"
        }
        
        let name = sections[section].name
        return "\((name == "") ? "No Category" : name)"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let num = numObjectsIn(section: section)
        return "\(num) item\((num == 1) ? "" : "s")"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // remove the item
            CoreDataService.context.delete(fetchedResultsController.object(at: indexPath))
            saveData()
        }
    }
    
    func updateTable(fromDataIn item: InventoryItemViewController, doIfSuccessful function: (() -> Void)? = nil) {
        // get the name from the relavent UITextField, stop if it's nil
        guard var name = item.nameTextField.text else {
            errorEmptyName(for: item)
            return
        }
        
        // trim whitespace, return if we are left with an empty string
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name == "" {
            errorEmptyName(for: item)
            return
        }
        
        // try to get the category from the relavent UITextField, if there is none, then use an empty string
        var category = ""
        if let categoryText = item.categoryTextField.text {
            category = categoryText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // try to get the category from the relavent UITextView, if there is none, then use an empty string
        var notes = ""
        if let notesText = item.notesTextView.text {
            notes = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // only make image not nil if the UImage in the UIImageView is not the default "Photo" resource
        var image: UIImage?
        if item.itemImageView.image != Utilities.defaultPlaceholderImage {
            image = item.itemImageView.image
        }
        
        if let incomingItem = item.incomingItem {
            incomingItem.name = name
            incomingItem.notes = notes
            incomingItem.categoryName = category
            incomingItem.accountedFor = item.accountedForSwitch.isOn
            
        }
        else {
            let newItem = CDItem(context: CoreDataService.context)
            newItem.name = name
            newItem.notes = notes
            newItem.categoryName = category
            newItem.image = image
            // TODO: Add image here
            newItem.accountedFor = item.accountedForSwitch.isOn
        }
        
        saveData()
        function?()
    }
    
    private func errorEmptyName(for sender: InventoryItemViewController) {
        let emptyNameError = UIAlertController(title: "Alert", message: "You did not provide a valid name. Please enter a name for this item.", preferredStyle: .alert)
        
        emptyNameError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        sender.present(emptyNameError, animated: true)
    }
    
    func saveData() {
        CoreDataService.saveContext()
    }
}

extension InventorizerTableViewDataSource: NSFetchedResultsControllerDelegate {
    func numObjectsIn(section: Int) -> Int {
        if section < fetchedResultsController.sections?.count ?? 0 {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
        else {
            return 0
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        tableView.reloadSectionIndexTitles()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
                break
            
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
                sectionWasRemoved = true
                break
            
            default:
                break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                guard let insertIndexPath = newIndexPath else {
                    break
                }
                tableView.insertRows(at: [insertIndexPath], with: .automatic)
                reloadSectionFooter(at: insertIndexPath.section)
                break
            
            case .delete:
                guard let deleteIndexPath = indexPath else {
                    break
                }
                tableView.deleteRows(at: [deleteIndexPath], with: .right)
                if (numObjectsIn(section: deleteIndexPath.section) != 0) {
                    reloadSectionFooter(at: deleteIndexPath.section)
                }
                break
            
            case .move:
                guard let beforeIndexPath = indexPath else {
                    break
                }
                guard let afterIndexPath = newIndexPath else {
                    break
                }
                tableView.moveRow(at: beforeIndexPath, to: afterIndexPath)
                if (beforeIndexPath.section != afterIndexPath.section) {
                    if (numObjectsIn(section: beforeIndexPath.section) != 0) {
                        reloadSectionFooter(at: beforeIndexPath.section)
                    }
                    reloadSectionFooter(at: afterIndexPath.section)
                }
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
