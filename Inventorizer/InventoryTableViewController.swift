//
//  ViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/3/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit
class InventoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var mainTable: UITableView!
    
    var buttonsNotEditing: [UIBarButtonItem]!
    var buttonsEditing: [UIBarButtonItem]!
    
    let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: #selector(trashTapped(_:)))
    let markButton = UIBarButtonItem(title: "Mark", style: .plain, target: nil, action: #selector(trashTapped(_:)))
    
    var itemsByCategory = [Category]()
    
    // MARK: Begin UITableViewDataSource funcs
    
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
        if editingStyle == .delete {
            // remove the item
            let category = itemsByCategory[indexPath.section]
            category.remove(at: indexPath.row)
            
            // remove the category if it's empty
            if category.numOfItems() == 0 {
                itemsByCategory.remove(at: indexPath.section)
            }
            
            tableView.reloadData()
        }
    }
    
    // MARK: End UITableViewDataSource funcs
    
    // MARK: Begin UITableViewDelegate funcs
    
    
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
    
    // MARK: End UITableViewDelegate funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        // make the button bar for when no editing is happening
        buttonsNotEditing = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: #selector(editToogleTapped(_:)))]
        
        // make the button bar for when editing is happening
        // disable trash and mark buttons by defualt
        trashButton.isEnabled = false
        markButton.isEnabled = false
        
        buttonsEditing = [trashButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), markButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(editToogleTapped(_:)))]
        
        // set the toolbar to have the not editing bar
        bottomToolBar.setItems(buttonsNotEditing, animated: false)
    }
    
    @objc func trashTapped(_ sender: Any) {
        
    }
    
    @objc func markTapped(_ sender: Any) {
        
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
            item.incomingItemToEdit = itemsByCategory[indexPath.section].getItem(at: indexPath.row)
            item.incomingItemCategory = itemsByCategory[indexPath.section]
            item.incomingItemCategoryIndex = indexPath.section
        }
    }
    
    // MARK: Begin Unwind funcs
    
    @IBAction func didUnwindSaveFromItem (_ sender: UIStoryboardSegue) {
        // only continue if we are unwinding from InventoryItemViewController
        guard let item = sender.source as? InventoryItemViewController else {
            return
        }
        
        // get the name from the relavent UITextField, stop if it's nil
        guard var name = item.nameTextField.text else {
            return
        }
        
        // trim whitespace, return if we are left with an empty string
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name == "" {
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
        if item.itemImageView.image != UIImage(named: "Photo") {
            image = item.itemImageView.image
        }
        
        let newItem = InventoryItem(name: name, category: category, notes: notes, image: image, accountedFor: item.accountedForSwitch.isOn)
        
        // handle case where an item changes categories
        if let editedItem = item.incomingItemToEdit, newItem.category != editedItem.category {
            item.incomingItemCategory!.remove(item: editedItem)
            if item.incomingItemCategory!.numOfItems() == 0 {
                itemsByCategory.remove(at: item.incomingItemCategoryIndex!)
            }
        }
        
        // bsearch for category
        let categoryIndex = Utilities.binarySearch(array: itemsByCategory, item: Category(name: category))
        if let existingCategoryIndex = categoryIndex {
            // bsearch for item
            let itemIndex = Utilities.binarySearch(array: itemsByCategory[existingCategoryIndex].getItems(), item: newItem)
            if let existingItemIndex = itemIndex {
                itemsByCategory[existingCategoryIndex].update(itemAt: existingItemIndex, with: newItem)
            }
            else {
                itemsByCategory[existingCategoryIndex].add(item: newItem)
            }
        }
        else {
            // category is not there, append a new category and sort
            itemsByCategory.append(Category(name: category, initialItems: [newItem]))
            itemsByCategory.sort()
        }
        
        self.mainTable.reloadData()
    }
    
    @IBAction func didUnwindCancelFromItem(_ sender: UIStoryboardSegue) {
        if let selectedRow = mainTable.indexPathForSelectedRow {
            self.mainTable.deselectRow(at: selectedRow, animated: false)
        }
        return
    }
    
    // MARK: End Unwind funcs    
}
