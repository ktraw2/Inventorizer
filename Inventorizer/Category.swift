//
//  Category.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/5/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation
class Category: Comparable, Hashable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    private var name: String
    private var items: [InventoryItem]
    
    init(name: String, initialItems: [InventoryItem]? = nil) {
        self.name = name
        
        if let unpackedInitialItems = initialItems {
            self.items = unpackedInitialItems
        }
        else {
            self.items = [InventoryItem]()
        }
    }
    
    public func add(item: InventoryItem) {
        items.append(item)
        items.sort()
    }
    
    public func remove(item: InventoryItem) {
        let foundIndex = Utilities.binarySearch(array: items, item: item)
        guard let removalIndex = foundIndex else {
            return
        }
        
        items.remove(at: removalIndex)
    }
    
    public func remove(at: Int) {
        items.remove(at: at)
    }
    
    public func update(itemAt index: Int, with newItem: InventoryItem) {
        if items[index] == newItem {
            items[index] = newItem
        }
    }
    
    public func getName() -> String {
        return name
    }
    
    public func getItems() -> [InventoryItem] {
        return items
    }
    
    public func numOfItems() -> Int {
        return items.count
    }
    
    public func getItem(at index: Int) -> InventoryItem {
        return items[index]
    }
}
