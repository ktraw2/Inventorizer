//
//  InventoryItem.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/3/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation
import UIKit
class InventoryItem: NSObject, Comparable {
    static func < (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        return lhs.name == rhs.name
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let castedObject = object as? InventoryItem else {
            return false
        }
        
        return self == castedObject
    }
    
    @objc var name: String
    @objc var category: String
    var notes: String
    var accountedFor: Bool
    var image: UIImage?
    
    init(name: String, category: String, notes: String, image: UIImage?, accountedFor: Bool = false) {
        self.name = name
        self.category = category
        self.notes = notes
        self.image = image
        self.accountedFor = accountedFor
    }
}
