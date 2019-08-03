//
//  CDItem+CoreDataClass.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/20/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CDItem)
public class CDItem: NSManagedObject {
//    override public var hash: Int {
//        return name.hashValue
//    }
}

extension CDItem: Comparable {
    public static func < (lhs: CDItem, rhs: CDItem) -> Bool {
        return lhs.name < rhs.name
    }
    
    public static func == (lhs: CDItem, rhs: CDItem) -> Bool {
        return lhs.name == rhs.name
    }
}
