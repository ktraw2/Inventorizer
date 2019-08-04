//
//  Utilities.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/5/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    private init() {}
    
    static let defaultPlaceholderImage = UIImage(named: "Photo")
    
    static func binarySearch<T:Comparable>(array: Array<T>, item: T) -> Int? {
        if array.count == 0 {
            return nil
        }
        
        var upperBound = array.count - 1
        var lowerBound = 0
        
        while (true) {
            let searchIndex = (upperBound - lowerBound / 2) + lowerBound
            if item == array[searchIndex] {
                return searchIndex
            }
            else if item < array[searchIndex] {
                upperBound = searchIndex - 1
                if upperBound < lowerBound {
                    return nil
                }
            }
            else {
                lowerBound = searchIndex + 1
                if lowerBound > upperBound {
                    return nil
                }
            }
        }
    }
    
    static func updateImage(for imageView: UIImageView, with imageOptional: UIImage?) {
        var image = defaultPlaceholderImage
        if let unpackedImage = imageOptional {
            image = unpackedImage
        }
        
        imageView.image = image
        
        if image == defaultPlaceholderImage {
            imageView.contentMode = .center
            imageView.backgroundColor = .lightGray
        }
        else {
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .none
        }
    }
}

extension Array {
    mutating func appendOptional(_ newElement: Element?) {
        guard let unwrapNewElement = newElement else {
            return
        }
        append(unwrapNewElement)
    }
}

extension Date {
    func dayMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        return formatter.string(from: self)
    }
    
    func year() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
}
