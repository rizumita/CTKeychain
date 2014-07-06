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
        case On, Off
    }
    
    struct Mode {
        static var instance = SynchronizationMode.On
    }

    class var synchronizationMode : SynchronizationMode {
        get {
            return Mode.instance
    }
        set {
            Mode.instance = newValue
    }
    }
    
}