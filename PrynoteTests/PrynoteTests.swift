//
//  PrynoteTests.swift
//  PrynoteTests
//
//  Created by tongyi on 2/19/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import XCTest
@testable import Prynote

class PrynoteTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_formattedElapse() {
        let elapse1: TimeInterval = 30
        let formatted1 = elapse1.formattedElapse()
        
        XCTAssertTrue(formatted1 == "00:00:30")
        
        let elapse2: TimeInterval = 60
        let formatted2 = elapse2.formattedElapse()
        
        XCTAssertTrue(formatted2 == "00:01:00")
        
        let elapse3: TimeInterval = 100
        let formatted3 = elapse3.formattedElapse()
        
        XCTAssertTrue(formatted3 == "00:01:40")
        
        let elapse4: TimeInterval = 3600
        let formatted4 = elapse4.formattedElapse()
        
        XCTAssertTrue(formatted4 == "01:00:00")
        
        let elapse5: TimeInterval = 3661
        let formatted5 = elapse5.formattedElapse()
        
        XCTAssertTrue(formatted5 == "01:01:01")
        
        let elapse6: TimeInterval = 100 * 3600 + 25*60  + 3
        let formatted6 = elapse6.formattedElapse()
        
        XCTAssertTrue(formatted6 == "100:25:03")
    }
}
