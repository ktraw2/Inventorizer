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
    // constants for saving and loading
    static private let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private let archiveURL: URL?
    var itemsByCategory: [Category]
    var sectionWasRemoved = false
    
    override init() {
        archiveURL = nil
        itemsByCategory = [Category]()
        super.init()
    }
    
    init(archiveName: String) {
        archiveURL = InventorizerTableViewDataSource.documentsDirectory.appendingPathComponent(archiveName)
        itemsByCategory = [Category]() // lol swift
        super.init()
        itemsByCategory = loadData()
    }
    
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
        
        let newItem = Item(name: name, category: category, notes: notes, image: image, accountedFor: item.accountedForSwitch.isOn)
        
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
                        dataCommit.shiftedCategoryIndex = existingCategoryIndex
                        dataCommit.shiftedItemIndex = existingItemIndex
                        dataCommit = self.commitStaged(referencing: item, using: dataCommit, sortingAgainst: newItem)
                        
                        self.itemsByCategory[dataCommit.shiftedCategoryIndex].update(itemAt: dataCommit.shiftedItemIndex, with: newItem)
                        self.saveData()
                        function?()
                    }))
                    
                    aboutToOverwriteWarning.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    
                    item.present(aboutToOverwriteWarning, animated: true)
                }
                else {
                    itemsByCategory[existingCategoryIndex].update(itemAt: existingItemIndex, with: newItem)
                    saveData()
                    function?()
                }
            }
            else {
                // we are working within the same category
                dataCommit.shiftedCategoryIndex = existingCategoryIndex
                dataCommit.mustKeepCategory = true
                dataCommit = commitStaged(referencing: item, using: dataCommit, sortingAgainst: newItem)
                
                itemsByCategory[dataCommit.shiftedCategoryIndex].add(item: newItem)
                saveData()
                function?()
            }
        }
        else {
            // category is not there, append a new category and sort
            dataCommit = commitStaged(referencing: item, using: dataCommit, sortingAgainst: newItem)
            
            itemsByCategory.append(Category(name: category, initialItems: [newItem]))
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
    
    private func commitStaged(referencing item: InventoryItemViewController, using commit: DataCommit, sortingAgainst newItem: Item) -> DataCommit {
        
        guard let editedItem = commit.stagedItem, let editedCategory = commit.stagedCategory else {
            return commit
        }
        
        var result = commit
        
        if editedCategory.category == Category(name: newItem.category) && editedItem < newItem {
            result.shiftedItemIndex -= 1
        }
        
        editedCategory.category.remove(item: editedItem)
        
        if editedCategory.category.numOfItems() == 0 && commit.mustKeepCategory == false {
            if editedCategory.category < Category(name: newItem.category) {
                result.shiftedCategoryIndex -= 1
            }
            
            itemsByCategory.remove(at: editedCategory.index)
        }
        
        return result
    }
    
    func saveData() {
        guard let unwrappedArchiveURL = archiveURL else {
            return
        }
        
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: self.itemsByCategory, requiringSecureCoding: false)
        
            try encodedData.write(to: unwrappedArchiveURL)
        }
        catch {
            // TODO
        }
    }
    
    private func loadData() -> [Category] {
        guard let unwrappedArchiveURL = archiveURL else {
            return [Category]()
        }
        
        do {
            let data = try Data(contentsOf: unwrappedArchiveURL)
            let unarchivedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            
            if let castedData = unarchivedData as? [Category] {
                return castedData
            }
            else {
                return [Category]()
            }
        }
        catch {
            return [Category]()
        }
    }
    
    private struct DataCommit {
        var stagedCategory: IndexedCategory?
        var stagedItem: Item?
        
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
