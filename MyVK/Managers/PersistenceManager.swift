//
//  PersistenceManager.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import Foundation

enum PersistenceManager {
    
    enum Keys {
        static let selectedTab = "selectedTab"
    }
    
    static var selectedTab = 0
    
    
    static func save() {
        print(String(describing: self), #function)
        UserDefaults.standard.set(selectedTab, forKey: Keys.selectedTab)
    }
    
    
    static func load() {
        print(String(describing: self), #function)
        selectedTab = UserDefaults.standard.object(forKey: Keys.selectedTab) as? Int ?? 0
    }
}
