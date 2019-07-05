//
//  Utilities.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/5/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import Foundation

class Utilities {
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
}
