//
//  CDItem+CoreDataProperties.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/21/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit.UIImage


extension CDItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDItem> {
        return NSFetchRequest<CDItem>(entityName: "CDItem")
    }

    @NSManaged public var accountedFor: Bool
    @NSManaged public var image: UIImage?
    @NSManaged public var name: String
    @NSManaged public var notes: String?
    @NSManaged public var categoryName: String
    @NSManaged public var tableID: UUID

}
