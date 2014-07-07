//
//  CTKeychain.swift
//  CTKeychain
//
//  Created by Ryoichi Izumita on 7/6/14.
//  Copyright (c) 2014 CAPH. All rights reserved.
//

import Foundation

class CTKeychain {
    
    enum SynchronizationMode {
        case On, Off, Any
    }
    
    struct Mode {
        static var instance = SynchronizationMode.Any
    }

    class var synchronizationMode : SynchronizationMode {
        get {
            return Mode.instance
    }
        set {
            Mode.instance = newValue
    }
    }
    
    class func errorMessageWithCode(code: OSStatus) -> String? {
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

    class func allItems(service: String, _ error: NSErrorPointer = nil) -> CTKeychainItem[] {
        let calcurateSynchronizable: (Void -> AnyObject) = {
            switch CTKeychain.synchronizationMode {
            case .On:
                return 1
            case .Off:
                return 0
            case .Any:
                return Unmanaged<NSData>.fromOpaque(kSecAttrSynchronizableAny.toOpaque()).takeUnretainedValue()
            }
        }
        let query = [
            Unmanaged<NSData>.fromOpaque(kSecClass.toOpaque()).takeUnretainedValue() : Unmanaged<NSData>.fromOpaque(kSecClassGenericPassword.toOpaque()).takeUnretainedValue(),
            Unmanaged<NSData>.fromOpaque(kSecAttrService.toOpaque()).takeUnretainedValue() : service,
            Unmanaged<NSData>.fromOpaque(kSecReturnAttributes.toOpaque()).takeUnretainedValue() : true,
            Unmanaged<NSData>.fromOpaque(kSecMatchLimit.toOpaque()).takeUnretainedValue() : Unmanaged<NSData>.fromOpaque(kSecMatchLimitAll.toOpaque()).takeUnretainedValue(),
            Unmanaged<NSData>.fromOpaque(kSecAttrSynchronizable.toOpaque()).takeUnretainedValue() : calcurateSynchronizable()
            ] as NSDictionary
        var dataTypeRef : Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(query as CFDictionaryRef, &dataTypeRef)
        var result : CTKeychainItem[] = []
        
        if Int(status) != errSecSuccess && error {
            if let message = CTKeychain.errorMessageWithCode(status) {
                error.memory = NSError.errorWithDomain(CTKeychainErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey : message])
            }
            
            return result
        }
        
        if let op = dataTypeRef?.toOpaque() {
            let retrieveDatas = Unmanaged<CFArrayRef>.fromOpaque(op).takeUnretainedValue() as NSArray
            for data : AnyObject in retrieveDatas {
                let dic = data as Dictionary<NSData, AnyObject>
                let dataAccount : AnyObject? = dic[Unmanaged<NSData>.fromOpaque(kSecAttrAccount.toOpaque()).takeUnretainedValue()]
                let dataSync : AnyObject? = dic[Unmanaged<NSData>.fromOpaque(kSecAttrSynchronizable.toOpaque()).takeUnretainedValue()]
                if let account : String = dataAccount as? String {
                    if let sync : Int = dataSync as? Int {
                        let item = CTKeychainItem(service: service, account: account, isSynchronized: sync == 1 ? true : false)
                        result += item
                    } else {
                        let item = CTKeychainItem(service: service, account: account)
                        result += item
                    }
                }
            }
        }
        
        return result
    }
    
}