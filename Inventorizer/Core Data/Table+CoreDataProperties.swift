//
//  Table+CoreDataProperties.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/23/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//
//

import Foundation
import CoreData


extension Table {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Table> {
        return NSFetchRequest<Table>(entityName: "Table")
    }

    @NSManaged public var name: String
    @NSManaged public var id: UUID
    @NSManaged public var notification: Date?

}
