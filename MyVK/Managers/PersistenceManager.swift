//
//  PersistenceManager.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import RealmSwift
import UIKit

enum PersistenceManager {
    
    // MARK: - UserDefaults -
    enum Keys {
        static let appId       = "appId"
        static let appVersion  = "CFBundleVersion"
        static let selectedTab = "selectedTab"
    }
    
    static let appVersion = Bundle.main.infoDictionary?[Keys.appVersion] as? String
    
    @UserDefault(key: Keys.appId, defaultValue: C.APP_IDS[0])
    static var appId: String
    
    @UserDefault(key: Keys.selectedTab, defaultValue: 0)
    static var selectedTab
    
    
    // MARK: - Realm -
    private static let realm = try? Realm(configuration: realmConfiguration, queue: .main)
    
    private static let realmConfiguration: Realm.Configuration = {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.deleteRealmIfMigrationNeeded = true
        configuration.objectTypes = [User.self, Group.self, Photo.self, Post.self, Attachment.self]
        return configuration
    }()
    
    
    static func create<T: Object & Identifiable>(_ object: T) -> T? {
        var createdObject: T?
        try? realm?.write {
            if let oldObject = realm?.object(ofType: T.self, forPrimaryKey: object.id) {
                createdObject = oldObject
            } else {
                createdObject = realm?.create(T.self, value: object, update: .modified)
            }
        }
        return createdObject
    }
    
    
    static func save(_ objects: Object...) {
        try? realm?.write {
            realm?.add(objects, update: .modified)
        }
    }
    
    
    static func save<T: Object>(_ objects: [T]?, in list: List<T>?) {
        guard let objects = objects, let list = list, let realm = try? Realm(configuration: realmConfiguration) else { return }
        try? realm.write {
            if list.count != objects.count {
                /* Update list after object deletion */
                list.removeAll()
            }
            for newObject in objects {
                if let newUser = newObject as? User,
                   let oldUser = realm.object(ofType: User.self, forPrimaryKey: newUser.id)
                {
                    /* Prevent overriding persisted lists by empty lists of newly decoded objects */
                    newUser.friends.append(objectsIn: oldUser.friends)
                    newUser.groups.append(objectsIn: oldUser.groups)
                    newUser.photos.append(objectsIn: oldUser.photos)
                    newUser.posts.append(objectsIn: oldUser.posts)
                    let newObject = realm.create(T.self, value: newObject, update: .modified)
                    guard list.index(of: newObject) == nil else { continue }
                    list.append(newObject)
                    
                } else if let newGroup = newObject as? Group,
                          let oldGroup = realm.object(ofType: Group.self, forPrimaryKey: newGroup.id)
                {
                    newGroup.posts.append(objectsIn: oldGroup.posts)
                    let newGroup = realm.create(T.self, value: newGroup, update: .modified)
                    guard list.index(of: newGroup) == nil else { continue }
                    list.append(newGroup)
                    
                } else {
                    let newObject = realm.create(T.self, value: newObject, update: .modified)
                    guard list.index(of: newObject) == nil else { continue }
                    list.append(newObject)
                }
            }
        }
    }
    
    
    static func load<T: Object>(_ type: T.Type, with primaryKey: Int) -> T? {
        realm?.object(ofType: T.self, forPrimaryKey: primaryKey)
    }
    
    
    static func delete<T: Object & Identifiable>(_ objects: T...) {
        try? realm?.write {
            for object in objects {
                if let object = realm?.object(ofType: T.self, forPrimaryKey: object.id) {
                    realm?.delete(object)
                }
            }
        }
    }
    
    
    static func pair<T: Object>(_ objects: List<T>, with tableView: UITableView?, token: inout NotificationToken?) {
        token = objects.observe { [weak tableView] changes in
            switch changes {
            case .initial(_):
                tableView?.reloadData()
            case .update(let updatedObjects, let deletions, let insertions, let modifications):
                tableView?.beginUpdates()
                if updatedObjects.isEmpty || updatedObjects.count == insertions.count {
                    /* Change section header for empty state and vice versa */
                    tableView?.reloadSections([0], with: .automatic)
                } else {
                    tableView?.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .left)
                    tableView?.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    tableView?.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                }
                tableView?.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
}
