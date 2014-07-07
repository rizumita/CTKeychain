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
            case .Any:
                self.isSynchronized = true
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
            if let message = CTKeychain.errorMessageWithCode(status) {
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
                if let message = CTKeychain.errorMessageWithCode(status) {
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
            if let message = CTKeychain.errorMessageWithCode(status) {
                error.memory = NSError(domain: CTKeychainErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey : message])
            }
        }
    
        return Int(status) == errSecSuccess
    }

}