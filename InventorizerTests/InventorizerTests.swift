//
//  InventorizerTests.swift
//  InventorizerTests
//
//  Created by Kevin Traw Jr on 7/5/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import XCTest
@testable import Inventorizer

class InventorizerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testBSearchItemInCenter() {
        let array = [5, 6, 7, 8, 9]
        XCTAssert(Utilities.binarySearch(array: array, item: 7) == 2)
    }
    
    func testBSearchItemAtZero() {
        let array = [5, 6, 7, 8, 9]
        XCTAssert(Utilities.binarySearch(array: array, item: 5) == 0)
    }
    
    func testBSearchItemAtEnd() {
        let array = [5, 6, 7, 8, 9]
        XCTAssert(Utilities.binarySearch(array: array, item: 9) == 4)
    }
    
    func testBSearchItemAboveHighest() {
        let array = [5, 6, 7, 8, 9]
        XCTAssert(Utilities.binarySearch(array: array, item: 11) == nil)
    }
    
    func testBSearchItemBelowLowest() {
        let array = [5, 6, 7, 8, 9]
        XCTAssert(Utilities.binarySearch(array: array, item: 4) == nil)
    }
    
    func testBSearchItemInLeftSide() {
        let array = [5, 6, 7, 8, 9]
        XCTAssert(Utilities.binarySearch(array: array, item: 6) == 1)
    }
    
    func testBSearchItemInRightSide() {
        let array = [5, 6, 7, 8, 9]
        XCTAssert(Utilities.binarySearch(array: array, item: 8) == 3)
    }
    
    func testBSearchItemNotInLeftSide() {
        let array = [2, 4, 6, 8, 10]
        XCTAssert(Utilities.binarySearch(array: array, item: 3) == nil)
    }
    
    func testBSearchItemNotInRightSide() {
        let array = [2, 4, 6, 8, 10]
        XCTAssert(Utilities.binarySearch(array: array, item: 7) == nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
