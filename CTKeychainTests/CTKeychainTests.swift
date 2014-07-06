//
//  CTKeychainTests.swift
//  CTKeychain
//
//  Created by Ryoichi Izumita on 7/6/14.
//  Copyright (c) 2014 CAPH. All rights reserved.
//

import XCTest

class CTKeychainTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        XCTAssertEqual(CTKeychain.synchronizationMode, CTKeychain.SynchronizationMode.On)

        CTKeychain.synchronizationMode = CTKeychain.SynchronizationMode.Off
        XCTAssertEqual(CTKeychain.synchronizationMode, CTKeychain.SynchronizationMode.Off)
    }

}
