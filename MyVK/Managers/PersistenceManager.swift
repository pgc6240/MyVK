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
    private static let realmConfiguration: Realm.Configuration = {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.deleteRealmIfMigrationNeeded = true
        configuration.objectTypes = [User.self, Group.self, Photo.self, Post.self]
        return configuration
    }()
    
    private static let realmQueue = DispatchQueue(label: "com.pgc6240.MyVK.realmQueue")
    
    private static var notificationTokens = Set<NotificationToken?>()
    
    
    // MARK: - Internal methods -
    private static func save(_ objects: [Object], in realm: Realm?) {
        for object in objects {
            if let user = object as? User {
                save(user, in: realm)
            } else if let group = object as? Group {
                save(group, in: realm)
            } else {
                realm?.add(object, update: .modified)
            }
        }
    }
    
    
    private static func save(_ user: User, in realm: Realm?) {
        if let storedUser = realm?.object(ofType: User.self, forPrimaryKey: user.id) {
            user.friends.append(objectsIn: storedUser.friends)
            user.groups.append(objectsIn: storedUser.groups)
            user.photos.append(objectsIn: storedUser.photos)
            user.posts.append(objectsIn: storedUser.posts)
            realm?.add(user, update: .modified)
        } else {
            realm?.add(user)
        }
    }
    
    
    private static func save(_ group: Group, in realm: Realm?) {
        if let storedGroup = realm?.object(ofType: Group.self, forPrimaryKey: group.id) {
            group.photos.append(objectsIn: storedGroup.photos)
            group.posts.append(objectsIn: storedGroup.posts)
            group.photosCount = group.photosCount == 0 ? storedGroup.photosCount : group.photosCount
            realm?.add(group, update: .modified)
        } else {
            realm?.add(group)
        }
    }
    
    
    // MARK: - External methods -
    static func save(_ objects: Object?...) {
        let objects = objects.compactMap { $0 }
        let realm = try? Realm(configuration: realmConfiguration)
        try? realm?.write {
            save(objects, in: realm)
        }
    }
    
    
    static func save<T: Object>(_ objects: [T]?, in list: List<T>?, completion: @escaping () -> Void = {}) {
        guard let objects = objects, let list = list else { return }
        let listReference = ThreadSafeReference(to: list)
        realmQueue.async {
            guard let realm = try? Realm(configuration: realmConfiguration),
                  let list = realm.resolve(listReference) else { return }
            try? realm.write {
                save(objects, in: realm)
                if list.count != objects.count {
                    list.removeAll()
                }
                for object in objects {
                    let object = realm.create(T.self, value: object, update: .modified)
                    guard list.index(of: object) == nil else { continue }
                    list.append(object)
                }
                DispatchQueue.main.async {
                    let realm = try? Realm(configuration: realmConfiguration)
                    realm?.refresh()
                    completion()
                }
            }
        }
    }
    
    
    static func load<T: Object>(_ type: T.Type, with primaryKey: Int?) -> T? {
        let realm = try? Realm(configuration: realmConfiguration)
        return realm?.object(ofType: T.self, forPrimaryKey: primaryKey)
    }
    
    
    static func load<T: ThreadConfined>(with reference: ThreadSafeReference<T>) -> T? {
        let realm = try? Realm(configuration: realmConfiguration)
        return realm?.resolve(reference)
    }
    
    
    static func delete<T: Object & Identifiable>(_ objects: T...) {
        DispatchQueue.main.async {
            let realm = try? Realm(configuration: realmConfiguration)
            try? realm?.write {
                for object in objects {
                    if let object = realm?.object(ofType: T.self, forPrimaryKey: object.id) {
                        realm?.delete(object)
                    }
                }
            }
        }
    }
    
    
    static func create<T: Object & Identifiable>(_ object: T) -> T {
        var createdObject: T!
        let realm = try! Realm(configuration: realmConfiguration)
        try! realm.write {
            if let oldObject = realm.object(ofType: T.self, forPrimaryKey: object.id) {
                createdObject = oldObject
            } else {
                createdObject = realm.create(T.self, value: object, update: .modified)
            }
        }
        return createdObject
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
