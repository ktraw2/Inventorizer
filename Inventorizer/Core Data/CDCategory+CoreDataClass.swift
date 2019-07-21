//
//  CDCategory+CoreDataClass.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/20/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CDCategory)
public class CDCategory: NSManagedObject {
//    override public var hash: Int {
//        return name.hashValue
//    }
}

extension CDCategory: Comparable {
    public static func < (lhs: CDCategory, rhs: CDCategory) -> Bool {
        return lhs.name < rhs.name
    }
    
    public static func == (lhs: CDCategory, rhs: CDCategory) -> Bool {
        return lhs.name == rhs.name
    }
}

struct CDIndexedCategory {
    var category: CDCategory
    var index: Int
}

struct CDCategorizedItem {
    var item: CDItem
    var indexedCategory: CDIndexedCategory
}
