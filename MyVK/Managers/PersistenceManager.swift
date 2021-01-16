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
            let realm = try Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true))
            realm.beginWrite()
            realm.add(objects, update: .all)
            try realm.commitWrite()
            print(realm.configuration.fileURL)
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
    
    
    static func delete(_ objects: [Object?]) {
        do {
            let realm = try Realm()
            let objects = objects.compactMap { $0 }
            realm.beginWrite()
            realm.delete(objects)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
}

