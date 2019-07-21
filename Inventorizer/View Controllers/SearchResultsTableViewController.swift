//
//  SearchResultsTableViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/7/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    var dataSource: InventorizerTableViewDataSource!
    var masterDataSource: InventorizerTableViewDataSource?
    var baseNavigationController: UINavigationController?
    var resultsToWholeCategoryMap = [CDCategory: CDIndexedCategory]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = InventorizerTableViewDataSource()
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        let selectedItemCategoryIndex = didSelectRowAt.section
        let selectedItemCategory = dataSource.itemsByCategory[selectedItemCategoryIndex]
        guard let selectedItem = selectedItemCategory.items.object(at: didSelectRowAt.row) as? CDItem else {
            return
        }
        
//        guard let itemViewController = InventoryItemViewController.buildItemControllerWith(selectedItem, resultsToWholeCategoryMap[selectedItemCategory], selectedItemCategoryIndex) else {
//            return
//        }
        guard let actualCategory = resultsToWholeCategoryMap[selectedItemCategory] else {
            return
        }
        
        guard let itemViewController = InventoryItemViewController.buildItemControllerWith(CDCategorizedItem(item: selectedItem, indexedCategory: actualCategory)) else {
            return
        }
        itemViewController.masterDataSource = masterDataSource
        
        baseNavigationController?.pushViewController(itemViewController, animated: true)
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}