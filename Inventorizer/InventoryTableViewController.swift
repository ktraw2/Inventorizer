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
//    var list = Array<InventoryItem>()
//    var categories = [String : [InventoryItem]]()
    
    var itemsByCategory = [Category]()
    
    
    var selectedItem: InventoryItem!
    
    // MARK: Begin UITableViewDataSource funcs
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        //cell.textLabel?.text = list[indexPath.row].name
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
            result.append("\(category.getName()) (\(category.numOfItems()))")
        }
        
        return result
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            itemsByCategory[indexPath.section].remove(at: indexPath.row)
//            removeFromList(item: Array(categories.values)[indexPath.section][indexPath.row])
//            updateCategories()
//            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
    
    // MARK: End UITableViewDataSource funcs
    
    // MARK: Begin UITableViewDelegate funcs
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        selectedItem = itemsByCategory[didSelectRowAt.section].getItem(at: didSelectRowAt.row)
        performSegue(withIdentifier: "EditItemSegue", sender: self)
    }
    
    // MARK: End UITableViewDelegate funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction @objc func editTapped(_ sender: Any) {
        guard let button = sender as? UIBarButtonItem else {
            return
        }
        
        for i in 0...((bottomToolBar.items?.count ?? 1) - 1) {
            if bottomToolBar.items?[i] === button {
                bottomToolBar.items?.remove(at: i)
                break
            }
        }
        
        if mainTable.isEditing {
            bottomToolBar.items?.append(UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: #selector(editTapped(_:))))
            mainTable.setEditing(false, animated: true)
        }
        else {
            bottomToolBar.items?.append(UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(editTapped(_:))))
            mainTable.setEditing(true, animated: true)
        }

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // only continue if we are going to InventoryItemViewController
        guard let item = segue.destination as? InventoryItemViewController else {
            return
        }
        item.currentItem = selectedItem
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
        
        
//        // remove old data if necessary
//        if let unpackedCurrentItem = item.currentItem {
//            removeFromList(item: unpackedCurrentItem)
//        }
//
//        // append to array and reload the data into the table
//        self.list.append(InventoryItem(name: name, category: category, notes: notes, image: image, accountedFor: item.accountedForSwitch.isOn))
//        //self.mainTable.insertRows(at: [IndexPath(row: list.count - 1, section: 0)], with: .automatic)
//        updateCategories()
//        self.mainTable.reloadData()
    }
    
    @IBAction func didUnwindCancelFromItem(_ sender: UIStoryboardSegue) {
        self.mainTable.reloadData()
        return
    }
    
    // MARK: End Unwind funcs
    

    
//    func removeFromList(item: InventoryItem) {
//        for i in 0...(list.count - 1) {
//            if list[i] === item {
//                list.remove(at: i)
//                break
//            }
//        }
//    }
//
//    func updateCategories() {
//        categories = [String : [InventoryItem]]()
//        for item in list {
//            print(item.name)
//            if var catrgoryArray = categories[item.category] {
//                catrgoryArray.append(item)
//            }
//            else {
//                categories[item.category] = [item]
//            }
//        }
//        print(categories)
//    }
    
}

