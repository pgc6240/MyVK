//
//  PersistenceManager.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

enum PersistenceManager {
    
    enum Keys {
        static let selectedTab = "selectedTab"
    }
    
    @UserDefault(key: Keys.selectedTab, defaultValue: 0)
    static var selectedTab
    
    
    static func save() {}
    
    static func load() {}
}

