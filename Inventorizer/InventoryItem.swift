//
//  InventoryItem.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/3/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation
import UIKit
class InventoryItem {
    var name: String
    var category: String
    var accountedFor: Bool
    var image: UIImage?
    
    init(name: String, category: String, image: UIImage?, accountedFor: Bool = false) {
        self.name = name
        self.category = category
        self.image = image
        self.accountedFor = accountedFor
    }
}
