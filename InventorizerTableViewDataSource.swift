//
//  InventorizerTableViewDataSource.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/7/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation
import UIKit

class InventorizerTableViewDataSource: NSObject, UITableViewDataSource {
    var itemsByCategory = [Category]()
    var sectionWasRemoved = false
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = itemsByCategory[indexPath.section].getItem(at: indexPath.row).name
        
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsByCategory[section].numOfItems()
    }
    
    func numberOfSections(in: UITableView) -> Int {
        return itemsByCategory.count
    }
    
    func sectionIndexTitles(for: UITableView) -> [String]? {
        var result = [String]()
        
        for category in itemsByCategory {
            let name = category.getName()
            result.append("\((name == "") ? "Uncategorized" : name) (\(category.numOfItems()))")
        }
        
        return result
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let name = itemsByCategory[section].getName()
        return "\((name == "") ? "Uncategorized" : name)"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let num = itemsByCategory[section].numOfItems()
        return "\(num) item\((num == 1) ? "" : "s")"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // in this func we actually want to affect itemsByCategory because this is the actual data
        if editingStyle == .delete {
            // remove the item
            tableView.beginUpdates()
            let category = itemsByCategory[indexPath.section]
            category.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // remove the category if it's empty
            if category.numOfItems() == 0 {
                itemsByCategory.remove(at: indexPath.section)
                sectionWasRemoved = true
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            tableView.endUpdates()
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
        
        let newItem = InventoryItem(name: name, category: category, notes: notes, image: image, accountedFor: item.accountedForSwitch.isOn)
        
        // handle case where an item changes categories or name
        // if we are changing categories or names we risk colliding with an already existing object, so this variable keeps track of the risk
        var itemIsChangingKeyData = false
        if let editedItem = item.incomingItemToEdit, (newItem.category != editedItem.category || newItem.name != editedItem.name) {
                itemIsChangingKeyData = true
//            else if newItem.name != editedItem.name {
//                itemIsChangingKeyData = true
//                item.incomingItemCategory!.remove(item: editedItem)
//            }
        }
        else {
            itemIsChangingKeyData = true
        }
        
        // bsearch for category
        let categoryIndex = Utilities.binarySearch(array: itemsByCategory, item: Category(name: category))
        if let existingCategoryIndex = categoryIndex {
            // bsearch for item
            let itemIndex = Utilities.binarySearch(array: itemsByCategory[existingCategoryIndex].getItems(), item: newItem)
            if let existingItemIndex = itemIndex {
                // determine if we are about to collide with an object that isn't the one we edited
                if itemIsChangingKeyData {
                    // we are, because the original object is gone based on code above, so give a warning
                    let aboutToOverwriteWarning = UIAlertController(title: "Overwrite data?", message: "The name or category you have given corresponds to an already existing item in the table. Do you want to overwrite this item? This action cannot be undone.", preferredStyle: .alert)
                    
                    aboutToOverwriteWarning.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {(_) in
                        var categoryIndexShift = 0
                        var itemIndexShift = 0
                        if let editedItem = item.incomingItemToEdit {
                            if item.incomingItemCategory!.getName() == category && editedItem.name < name {
                                itemIndexShift = 1
                            }
                            
                            item.incomingItemCategory!.remove(item: editedItem)
                            if item.incomingItemCategory!.numOfItems() == 0 {
                                if item.incomingItemCategory!.getName() < category {
                                    categoryIndexShift = 1
                                }
                                self.itemsByCategory.remove(at: item.incomingItemCategoryIndex!)
                            }
                        }
                        
                        self.itemsByCategory[existingCategoryIndex - categoryIndexShift].update(itemAt: existingItemIndex - itemIndexShift, with: newItem)
                        function?()
                    }))
                    
                    aboutToOverwriteWarning.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    
                    item.present(aboutToOverwriteWarning, animated: true)
                }
                else {
                    itemsByCategory[existingCategoryIndex].update(itemAt: existingItemIndex, with: newItem)
                    function?()
                }
            }
            else {
                itemsByCategory[existingCategoryIndex].add(item: newItem)
                function?()
            }
        }
        else {
            // category is not there, append a new category and sort
            itemsByCategory.append(Category(name: category, initialItems: [newItem]))
            itemsByCategory.sort()
            function?()
        }
    }
    
    private func errorEmptyName(for sender: InventoryItemViewController) {
        let emptyNameError = UIAlertController(title: "Warning", message: "You did not provide a valid name. Please enter a name for this item.", preferredStyle: .alert)
        
        emptyNameError.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        sender.present(emptyNameError, animated: true)
    }
}
