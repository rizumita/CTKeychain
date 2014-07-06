//
//  CTKeychain.swift
//  CTKeychain
//
//  Created by Ryoichi Izumita on 2014/06/14.
//  Copyright (c) 2014 CAPH. All rights reserved.
//

import Foundation
import Security

let CTKeychainErrorDomain = "CTKeychainErrorDomain"

class CTKeychainItem {
    
    var service: String
    var account: String
    var isSynchronized: Bool
    
    var password: String? {
    get {
        return getPassword()
    }
    set {
        setPassword(newValue)
    }
    }
    
    init(service: String, account: String, isSynchronized: Bool? = nil) {
        self.service = service
        self.account = account
        
        if let sync = isSynchronized {
            self.isSynchronized = sync
        } else {
            switch CTKeychain.synchronizationMode {
            case .On:
                self.isSynchronized = true
            case .Off:
                self.isSynchronized = false
            }
        }
    }
    
    func getPassword(error: NSErrorPointer = nil) -> String? {
        var dataTypeRef: Unmanaged<AnyObject>?
        let query = [
            Unmanaged<NSData>.fromOpaque(kSecClass.toOpaque()).takeUnretainedValue() : Unmanaged<NSData>.fromOpaque(kSecClassGenericPassword.toOpaque()).takeUnretainedValue(),
            Unmanaged<NSData>.fromOpaque(kSecAttrService.toOpaque()).takeUnretainedValue() : service,
            Unmanaged<NSData>.fromOpaque(kSecAttrAccount.toOpaque()).takeUnretainedValue() : account,
            Unmanaged<NSData>.fromOpaque(kSecReturnData.toOpaque()).takeUnretainedValue() : true,
            Unmanaged<NSData>.fromOpaque(kSecMatchLimit.toOpaque()).takeUnretainedValue() : Unmanaged<NSData>.fromOpaque(kSecMatchLimitOne.toOpaque()).takeUnretainedValue(),
            Unmanaged<NSData>.fromOpaque(kSecAttrSynchronizable.toOpaque()).takeUnretainedValue() : isSynchronized
            ] as NSDictionary
        let status = SecItemCopyMatching(query as CFDictionaryRef, &dataTypeRef)

        if Int(status) != errSecSuccess && error {
            if let message = errorMessageWithCode(status) {
                error.memory = NSError.errorWithDomain(CTKeychainErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey : message])
            }
            
            return nil
        }
        
        if let op = dataTypeRef?.toOpaque() {
            let retrieveData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            if retrieveData.length > 0 {
                return NSString(data: retrieveData, encoding: NSUTF8StringEncoding)
            }
        }
        
        return nil
    }
    
    func setPassword(newPassword: String?, error: NSErrorPointer = nil) -> Bool {
        let deleted = self.deleteItem(error: error)
        if !deleted && error {
            return false
        }

        if let password = newPassword {
            var secret: NSData = password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            let query = [
                Unmanaged<NSData>.fromOpaque(kSecClass.toOpaque()).takeUnretainedValue() : Unmanaged<NSData>.fromOpaque(kSecClassGenericPassword.toOpaque()).takeUnretainedValue(),
                Unmanaged<NSData>.fromOpaque(kSecAttrService.toOpaque()).takeUnretainedValue() : service,
                Unmanaged<NSData>.fromOpaque(kSecAttrAccount.toOpaque()).takeUnretainedValue() : account,
                Unmanaged<NSData>.fromOpaque(kSecValueData.toOpaque()).takeUnretainedValue() : secret,
                Unmanaged<NSData>.fromOpaque(kSecAttrSynchronizable.toOpaque()).takeUnretainedValue() : isSynchronized] as NSDictionary
            let status = SecItemAdd(query as CFDictionaryRef, nil)
            if Int(status) != errSecSuccess && error {
                if let message = errorMessageWithCode(status) {
                    error.memory = NSError.errorWithDomain(CTKeychainErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey : message])
                }
            }
            
            return Int(status) == errSecSuccess
        } else {
            return true
        }
    }
 
    func deleteItem(error: NSErrorPointer = nil) -> Bool {
        let query = [
            Unmanaged<NSData>.fromOpaque(kSecClass.toOpaque()).takeUnretainedValue() : Unmanaged<NSData>.fromOpaque(kSecClassGenericPassword.toOpaque()).takeUnretainedValue(),
            Unmanaged<NSData>.fromOpaque(kSecAttrService.toOpaque()).takeUnretainedValue() : service,
            Unmanaged<NSData>.fromOpaque(kSecAttrAccount.toOpaque()).takeUnretainedValue() : account,
            Unmanaged<NSData>.fromOpaque(kSecAttrSynchronizable.toOpaque()).takeUnretainedValue() : isSynchronized
            ] as NSDictionary
        let status = SecItemDelete(query as CFDictionaryRef)
        if Int(status) != errSecSuccess && error {
            if let message = errorMessageWithCode(status) {
                error.memory = NSError(domain: CTKeychainErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey : message])
            }
        }
    
        return Int(status) == errSecSuccess
    }

    func errorMessageWithCode(code: OSStatus) -> String? {
        switch (Int(code)) {
        case errSecSuccess:
            return nil;
        case errSecUnimplemented:
            return NSLocalizedString("errorSecUnimplemented", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errorSecUnimplemented")
        case errSecParam:
            return NSLocalizedString("errSecParam", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errSecParam")
        case errSecAllocate:
            return NSLocalizedString("errSecAllocate", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errSecAllocate")
        case errSecNotAvailable:
            return NSLocalizedString("errSecNotAvailable", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errSecNotAvailable")
        case errSecDuplicateItem:
            return NSLocalizedString("errSecDuplicateItem", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errSecDuplicateItem")
        case errSecItemNotFound:
            return NSLocalizedString("errSecItemNotFound", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errSecItemNotFound")
        case errSecInteractionNotAllowed:
            return NSLocalizedString("errSecInteractionNotAllowed", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errSecInteractionNotAllowed")
        case errSecDecode:
            return NSLocalizedString("errSecDecode", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errSecDecode")
        case errSecAuthFailed:
            return NSLocalizedString("errSecAuthFailed", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errSecAuthFailed")
        default:
            return NSLocalizedString("errSecDefault", tableName: "CTKeychain", bundle: NSBundle(forClass: CTKeychainItem.self), comment: "errSecDefault")
        }
    }
}