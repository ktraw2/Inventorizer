//
//  CDItem+CoreDataProperties.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/20/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//
//

import Foundation
import CoreData


extension CDItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDItem> {
        return NSFetchRequest<CDItem>(entityName: "CDItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var accountedFor: Bool
    @NSManaged public var image: NSData?
    @NSManaged public var category: CDCategory?

}
