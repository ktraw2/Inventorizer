//
//  ViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/3/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit
class InventoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainTable: UITableView!
    var list = Array<InventoryItem>()
    var currentItemIndex = 0
    
    // Begin UITableViewDelegate funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(list.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = list[indexPath.row].name
        
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        currentItemIndex = didSelectRowAt.row
        performSegue(withIdentifier: "EditItemSegue", sender: self)
    }
    
    // End UITableViewDelegate funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        
//        let askItemName: UIAlertController = UIAlertController(title: "New Item", message: "Please enter the name:", preferredStyle: .alert)
//        askItemName.addTextField{
//            (textField) in
//            textField.placeholder = "Item Name"
//        }
//
//        askItemName.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak askItemName] (_) in
//            if let itemNameField = askItemName?.textFields?[0], let itemName = itemNameField.text {
//                self.list.append(InventoryItem(name: itemName, category: "lol", image: nil))
//                self.mainTable.reloadData()
//            }
//        }))
//
//        askItemName.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        self.present(askItemName, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // only continue if we are going to InventoryItemViewController
        guard let item = segue.destination as? InventoryItemViewController else {
            return
        }
        item.currentItem = list[currentItemIndex]
    }
    
    // Begin Unwind funcs
    
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
        if let categoryText = item.categoryTextField.text  {
            category = categoryText
        }
        
        // only make image not nil if the UImage in the UIImageView is not the default "Photo" resource
        var image: UIImage?
        if item.itemImageView.image != UIImage(named: "Photo") {
            image = item.itemImageView.image
        }
        
        // remove old data if necessary
        if let unpackedCurrentItem = item.currentItem {
            for i in 0...(list.count - 1) {
                if list[i] === unpackedCurrentItem {
                    list.remove(at: i)
                    break
                }
            }
        }
        
        // append to array and reload the data into the table
        self.list.append(InventoryItem(name: name, category: category, image: image, accountedFor: item.accountedForSwitch.isOn))
        self.mainTable.reloadData()
    }
    
    @IBAction func didUnwindCancelFromItem(_ sender: UIStoryboardSegue) {
        self.mainTable.reloadData()
        return
    }
    
    // End Unwind funcs
    
}

