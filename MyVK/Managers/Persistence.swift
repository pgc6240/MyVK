//
//  Persistence.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import Foundation

enum Persistence {
    
    enum Keys {
        static let selectedTab = "selectedTab"
    }
    
    
    @UserDefault(key: String(describing: Keys.selectedTab), defaultValue: 0)
    static var selectedTab
    
    
    static func save() {
        //print(String(describing: self), #function, selectedTab)
        
    }
    
    
    static func load() {
        //print(String(describing: self), #function, selectedTab)
        
    }
}


//
// MARK: - UserDefault
//
@propertyWrapper
struct UserDefault<T> {
    
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
