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

    func testSynchronizationMode() {
        XCTAssertEqual(CTKeychain.synchronizationMode, CTKeychain.SynchronizationMode.Any)

        CTKeychain.synchronizationMode = CTKeychain.SynchronizationMode.Off
        XCTAssertEqual(CTKeychain.synchronizationMode, CTKeychain.SynchronizationMode.Off)

        CTKeychain.synchronizationMode = CTKeychain.SynchronizationMode.On
        XCTAssertEqual(CTKeychain.synchronizationMode, CTKeychain.SynchronizationMode.On)
    }
    
    func testAllItems() {
        CTKeychain.synchronizationMode = CTKeychain.SynchronizationMode.Any
        let service = "CTKeychain"
        var item = CTKeychainItem(service: service, account: "Account1")
        item.password = "testpass1"
        item = CTKeychainItem(service: service, account: "Account2")
        item.password = "testpass2"
        
        let items = CTKeychain.allItems(service)
        XCTAssertGreaterThanOrEqual(items.count, 2)
    }

}
