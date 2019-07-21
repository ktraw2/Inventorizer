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

    //var itemsByCategory: [CDCategory]
    var fetchedResultsController: NSFetchedResultsController<CDItem>
    var sectionWasRemoved = false
    
    override init() {
        let fetchRequest: NSFetchRequest<CDItem> = CDItem.fetchRequest()
        let categorySorting = NSSortDescriptor(key: "category.name", ascending: true)
        let nameSorting = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [categorySorting, nameSorting]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.context, sectionNameKeyPath: nil, cacheName: nil)
        
//        do {
//            let itemsByCategory = try CoreDataService.context.fetch(fetchRequest)
//            self.itemsByCategory = itemsByCategory
//        }
//        catch {
//            fatalError("Error!")
//        }
        
        super.init()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        guard let item = itemsByCategory[indexPath.section].items.object(at: indexPath.row) as? CDItem else {
            cell.textLabel?.text = "ERROR"
            return cell
        }
        
        cell.textLabel?.text = item.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in: UITableView) -> Int {
        return itemsByCategory.count
    }
    
    func sectionIndexTitles(for: UITableView) -> [String]? {
        var result = [String]()
        
        for category in itemsByCategory {
            let name = category.name
            result.append("\((name == "") ? "Uncategorized" : name) (\(category.items.count))")
        }
        
        return result
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let name = itemsByCategory[section].name
        return "\((name == "") ? "Uncategorized" : name)"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let num = itemsByCategory[section].items.count
        return "\(num) item\((num == 1) ? "" : "s")"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // in this func we actually want to affect itemsByCategory because this is the actual data
        if editingStyle == .delete {
            // remove the item
            tableView.beginUpdates()
            let category = itemsByCategory[indexPath.section]
            category.removeFromItems(at: indexPath.row)
            CoreDataService.context.delete(category)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // remove the category if it's empty
            if category.items.count == 0 {
                itemsByCategory.remove(at: indexPath.section)
                CoreDataService.context.delete(category)
                sectionWasRemoved = true
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            tableView.endUpdates()
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
        
        let newItem = CDItem(context: CoreDataService.context)
        newItem.name = name
        newItem.notes = notes
        // TODO: Add image here
        newItem.accountedFor = item.accountedForSwitch.isOn
        
        // handle case where an item changes categories or name
        // if we are changing categories or names we risk colliding with an already existing object, so this variable keeps track of the risk
        var itemIsChangingKeyData = false
        var dataCommit = DataCommit()
        
        if let incomingData = item.incomingData {
            if newItem.category != incomingData.item.category || newItem.name != incomingData.item.name {
                itemIsChangingKeyData = true
                dataCommit.stagedCategory = incomingData.indexedCategory
                dataCommit.stagedItem = incomingData.item
            }
            
        }
        else {
            itemIsChangingKeyData = true
        }
        
        // bsearch for category
        let dummyCategory = CDCategory(context: CoreDataService.context)
        dummyCategory.name = category
        
        let categoryIndex = Utilities.binarySearch(array: itemsByCategory, item: dummyCategory)
        print(categoryIndex)
        
        CoreDataService.context.delete(dummyCategory)
        
        if let existingCategoryIndex = categoryIndex {
            // bsearch for item
            let itemIndex = Utilities.binarySearch(array: itemsByCategory[existingCategoryIndex].items.array as! [CDItem], item: newItem)
            if let existingItemIndex = itemIndex {
                // determine if we are about to collide with an object that isn't the one we edited
                if itemIsChangingKeyData {
                    // we are, because the original object is gone based on code above, so give a warning
                    let aboutToOverwriteWarning = UIAlertController(title: "Overwrite data?", message: "The name or category you have given corresponds to an already existing item in the table. Do you want to overwrite this item? This action cannot be undone.", preferredStyle: .alert)
                    
                    aboutToOverwriteWarning.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {(_) in
                        dataCommit.shiftedCategoryIndex = existingCategoryIndex
                        dataCommit.shiftedItemIndex = existingItemIndex
                        dataCommit = self.commitStaged(referencing: item, using: dataCommit, sortingAgainst: newItem)
                        
                        let category = self.itemsByCategory[dataCommit.shiftedCategoryIndex]
                        newItem.category = category
                        
                        category.replaceItems(at: dataCommit.shiftedItemIndex, with: newItem)
                        self.saveData()
                        function?()
                    }))
                    
                    aboutToOverwriteWarning.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(_) in
                        CoreDataService.context.delete(newItem)
                    }))
                    
                    item.present(aboutToOverwriteWarning, animated: true)
                }
                else {
                    let category = itemsByCategory[existingCategoryIndex]
                    newItem.category = category
                    
                    category.replaceItems(at: existingItemIndex, with: newItem)
                    saveData()
                    function?()
                }
            }
            else {
                // we are working within the same category
                dataCommit.shiftedCategoryIndex = existingCategoryIndex
                dataCommit.mustKeepCategory = true
                dataCommit = commitStaged(referencing: item, using: dataCommit, sortingAgainst: newItem)
                
                let category = itemsByCategory[dataCommit.shiftedCategoryIndex]
                newItem.category = category
                
                category.addToItems(newItem)
                saveData()
                function?()
            }
        }
        else {
            // category is not there, append a new category and sort
            dataCommit = commitStaged(referencing: item, using: dataCommit, sortingAgainst: newItem)
            
            let newCategory = CDCategory(context: CoreDataService.context)
            newCategory.name = category
            newCategory.addToItems(newItem)
            newItem.category = newCategory
            
            itemsByCategory.append(newCategory)
            itemsByCategory.sort()
            saveData()
            function?()
        }
    }
    
    private func errorEmptyName(for sender: InventoryItemViewController) {
        let emptyNameError = UIAlertController(title: "Warning", message: "You did not provide a valid name. Please enter a name for this item.", preferredStyle: .alert)
        
        emptyNameError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        sender.present(emptyNameError, animated: true)
    }
    
    private func commitStaged(referencing item: InventoryItemViewController, using commit: DataCommit, sortingAgainst newItem: CDItem) -> DataCommit {
        
        guard let editedItem = commit.stagedItem, let editedCategory = commit.stagedCategory else {
            return commit
        }
        
        var result = commit
        
        if editedCategory.category == newItem.category && editedItem < newItem {
            result.shiftedItemIndex -= 1
        }
        
        editedCategory.category.removeFromItems(editedItem)
        
        if editedCategory.category.items.count == 0 && commit.mustKeepCategory == false {
            if editedCategory.category < newItem.category {
                result.shiftedCategoryIndex -= 1
            }
            
            itemsByCategory.remove(at: editedCategory.index)
        }
        
        return result
    }
    
    func saveData() {
        CoreDataService.saveContext()
    }
    
    private struct DataCommit {
        var stagedCategory: CDIndexedCategory?
        var stagedItem: CDItem?
        
        var mustKeepCategory: Bool
        
        var shiftedItemIndex: Int
        var shiftedCategoryIndex: Int
        
        init() {
            mustKeepCategory = false
            shiftedItemIndex = 0
            shiftedCategoryIndex = 0
        }
    }
}
