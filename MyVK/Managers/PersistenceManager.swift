//
//  PersistenceManager.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import Foundation
import RealmSwift

enum PersistenceManager {
    
    enum Keys {
        static let appVersion  = "CFBundleVersion"
        static let selectedTab = "selectedTab"
    }
    
    static let appVersion = Bundle.main.infoDictionary?[Keys.appVersion] as? String
    
    @UserDefault(key: Keys.selectedTab, defaultValue: 2)
    static var selectedTab
    
    
    static func save(_ objects: [Object]) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(objects, update: .modified)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    static func load<T: Object>(_ type: T.Type) -> [T]? {
        do {
            let realm = try Realm()
            let objects: [T] = realm.objects(type).map { $0 }
            return objects
        } catch {
            print(error)
        }
        return nil
    }
}

