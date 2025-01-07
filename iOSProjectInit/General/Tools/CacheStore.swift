//
//  PropertyWrapper.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/10/27.
//

import Foundation

typealias CacheStoreKey = String

extension CacheStoreKey {
    static let kToken = "kToken"
    static let kLastAccount = "kLastAccount"
    static let kLastPhone = "kLastPhone"
    static let kManyTenant = "kManyTenant"
    static let kIsFirstLaunch = "kIsFirstLaunch"
    static let kUserJson = "kUserJson"
    static let kIsCodeLogin = "kIsCodeLogin"
}

@propertyWrapper
struct CacheStore<T> {
    let key: CacheStoreKey
    let defaultValue: T
    
    var wrappedValue: T {
        mutating get {
            if let value = _value {
                return value
            }
            if let value = UserDefaults.standard.object(forKey: key) as? T {
                _value = value
                return value
            } else {
                return defaultValue
            }
        }
        set {
            _value = newValue
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
    var projectedValue: Self { self }
    
    mutating func remove() {
        _value = nil
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    var _value: T?
}
