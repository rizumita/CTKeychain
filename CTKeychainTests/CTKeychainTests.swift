//
//  CTKeychainTests.swift
//  CTKeychainTests
//
//  Created by Ryoichi Izumita on 2014/06/14.
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
    
    func testGetAndSetPassword() {
        let service = "CTKeychain"
        let account = "MyAccount"
        let item = CTKeychainItem(service: service, account: account)
        item.password = "testpass"
        let password = item.password
        if let actualPassword = password {
            XCTAssertEqual("testpass", actualPassword)
        } else {
            XCTFail()
        }
    }
    
    func testGetPasswordWithError() {
        let item = CTKeychainItem(service: "CTKeychain", account: "withError")
        var error: NSError? = nil
        let password = item.getPassword(error: &error)
        println(error)
        XCTAssertNotNil(error)
    }
    
}
