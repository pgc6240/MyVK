//
//  PersistenceManager.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import Foundation
import RealmSwift

enum PersistenceManager {
    
    // MARK: - UserDefaults -
    enum Keys {
        static let appVersion  = "CFBundleVersion"
        static let selectedTab = "selectedTab"
    }
    
    static let appVersion = Bundle.main.infoDictionary?[Keys.appVersion] as? String
    
    @UserDefault(key: Keys.selectedTab, defaultValue: 0)
    static var selectedTab
    
    
    // MARK: - Realm -
    private static let realmConfiguration: Realm.Configuration = {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.deleteRealmIfMigrationNeeded = true
        return configuration
    }()
    
    
    static func save(_ objects: [Object]) {
        do {
            let realm = try Realm(configuration: realmConfiguration)
            realm.beginWrite()
            realm.add(objects, update: .modified)
            try realm.commitWrite()
            print(realm.configuration.fileURL ?? "")
        } catch {
            print(error)
        }
    }
    
    
    static func load<T: Object>(_ type: T.Type) -> [T]? {
        do {
            let realm = try Realm(configuration: realmConfiguration)
            let objects: [T] = realm.objects(type).map { $0 }
            return objects
        } catch {
            print(error)
            return nil
        }
    }
    
    
    static func delete(_ objects: [Object]) {
        do {
            let realm = try Realm(configuration: realmConfiguration)
            realm.beginWrite()
            realm.delete(objects)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
}

