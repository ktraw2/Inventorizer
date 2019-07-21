//
//  Category.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/5/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation
class Category: NSObject, NSCoding, Comparable {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(items, forKey: PropertyKey.items)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            return nil
        }
        
        guard let items = aDecoder.decodeObject(forKey: PropertyKey.items) as? [InventoryItem] else {
            return nil
        }
        
        self.init(name: name, initialItems: items)
    }
    
    static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
    
    override var hash: Int {
        return name.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Category else {
            return false
        }
        
        return self == rhs
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
    
    private struct PropertyKey {
        static let name = "name"
        static let items = "items"
    }
}

struct IndexedCategory {
    var category: Category
    var index: Int
}

struct CategorizedItem {
    var item: InventoryItem
    var indexedCategory: IndexedCategory
}
