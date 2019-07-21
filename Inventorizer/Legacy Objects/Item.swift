//
//  InventoryItem.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/3/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation
import UIKit
class Item: NSObject, NSCoding, Comparable {
    static func < (lhs: Item, rhs: Item) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.name == rhs.name
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let castedObject = object as? Item else {
            return false
        }
        
        return self == castedObject
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(1, forKey: PropertyKey.version)
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(notes, forKey: PropertyKey.notes)
        aCoder.encode(accountedFor, forKey: PropertyKey.accountedFor)
        aCoder.encode(image, forKey: PropertyKey.image)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            return nil
        }
        
        guard let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? String else {
            return nil
        }
        
        guard let notes = aDecoder.decodeObject(forKey: PropertyKey.notes) as? String else {
            return nil
        }
        
        guard let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage? else {
            return nil
        }
        
        let accountedFor = aDecoder.decodeBool(forKey: PropertyKey.accountedFor)
        
        self.init(name: name, category: category, notes: notes, image: image, accountedFor: accountedFor)
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

    private struct PropertyKey {
        static let version = "version"
        static let name = "name"
        static let category = "category"
        static let notes = "notes"
        static let image = "image"
        static let accountedFor = "accountedFor"
    }
}
