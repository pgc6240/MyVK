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
        configuration.objectTypes = [User.self, Group.self, Photo.self, Post.self]
        return configuration
    }()
    
    private static var notificationTokens: Set<NotificationToken?> = []
    
    
    // MARK: - Internal methods -
    private static func save(_ user: User) {
        if let oldUser = realm?.object(ofType: User.self, forPrimaryKey: user.id) {
            user.friends.append(objectsIn: oldUser.friends)
            user.groups.append(objectsIn: oldUser.groups)
            user.photos.append(objectsIn: oldUser.photos)
            user.posts.append(objectsIn: oldUser.posts)
            user.newsfeed.append(objectsIn: oldUser.newsfeed)
            realm?.add(user, update: .modified)
        } else {
            realm?.add(user)
        }
    }
    
    
    private static func save(_ group: Group) {
        if let oldGroup = realm?.object(ofType: Group.self, forPrimaryKey: group.id) {
            group.photos.append(objectsIn: oldGroup.photos)
            group.posts.append(objectsIn: oldGroup.posts)
            group.photosCount = group.photosCount == 0 ? oldGroup.photosCount : group.photosCount
            realm?.add(group, update: .modified)
        } else {
            realm?.add(group)
        }
    }
    
    
    // MARK: - External methods -
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
            for object in objects {
                if let user = object as? User {
                    save(user)
                } else if let group = object as? Group {
                    save(group)
                }
            }
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
                    newUser.newsfeed.append(objectsIn: oldUser.newsfeed)
                    let newObject = realm.create(T.self, value: newObject, update: .modified)
                    guard list.index(of: newObject) == nil else { continue }
                    list.append(newObject)
                    
                } else if let newGroup = newObject as? Group,
                          let oldGroup = realm.object(ofType: Group.self, forPrimaryKey: newGroup.id)
                {
                    newGroup.photos.append(objectsIn: oldGroup.photos)
                    newGroup.posts.append(objectsIn: oldGroup.posts)
                    newGroup.photosCount = newGroup.photosCount == 0 ? oldGroup.photosCount : newGroup.photosCount
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
    
    
    static func load<T: ThreadConfined>(with reference: ThreadSafeReference<T>) -> T? {
        let realm = try? Realm(configuration: realmConfiguration)
        return realm?.resolve(reference)
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
    
    
    // MARK: - Realm Notifications -
    static func pair<T: Object>(_ objects: List<T>?, with tableView: UITableView?, onChange: @escaping () -> Void = {}) {
        let token = objects?.observe { [weak tableView] changes in
            switch changes {
            case .initial(_):
                onChange()
                tableView?.reloadData()
            case .update(let updatedObjects, let deletions, let insertions, let modifications):
                onChange()
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
        notificationTokens.insert(token)
    }
}
