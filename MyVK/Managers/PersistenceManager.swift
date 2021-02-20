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
    private static let realm: () -> Realm? = {
        do {
            return try Realm(configuration: realmConfiguration)
        } catch {
            realmConfiguration.inMemoryIdentifier = "com.pgc6240.MyVK.realm"
            return try? Realm(configuration: realmConfiguration)
        }
    }
    
    private static var realmConfiguration: Realm.Configuration = {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.deleteRealmIfMigrationNeeded = true
        configuration.objectTypes = [User.self, Group.self, Photo.self, Post.self]
        return configuration
    }()
    
    private static let realmQueue = DispatchQueue(label: "com.pgc6240.MyVK.realmQueue")
    
    private static var notificationTokens = Set<NotificationToken?>()
    
    
    // MARK: - Internal methods -
    @discardableResult
    private static func save<T: Object>(_ object: T, in realm: Realm) -> T {
        if let user = object as? User {
            return save(user, in: realm) as! T
        } else if let group = object as? Group {
            return save(group, in: realm) as! T
        } else {
            return realm.create(T.self, value: object, update: .modified)
        }
    }
    
    
    @discardableResult
    private static func save(_ newUser: User, in realm: Realm) -> User {
        if let oldUser = realm.object(ofType: User.self, forPrimaryKey: newUser.id) {
            newUser.friends.append(objectsIn: oldUser.friends)
            newUser.groups.append(objectsIn: oldUser.groups)
            newUser.photos.append(objectsIn: oldUser.photos)
            newUser.posts.append(objectsIn: oldUser.posts)
            newUser.friendsCount = newUser.friendsCount == -1 ? oldUser.friendsCount : newUser.friendsCount
            newUser.groupsCount = newUser.groupsCount == -1 ? oldUser.groupsCount : newUser.groupsCount
            newUser.photosCount = newUser.photosCount == -1 ? oldUser.photosCount : newUser.photosCount
            newUser.postsCount = newUser.postsCount == -1 ? oldUser.postsCount : newUser.postsCount
            return realm.create(User.self, value: newUser, update: .modified)
        } else {
            return realm.create(User.self, value: newUser)
        }
    }
    
    
    @discardableResult
    private static func save(_ newGroup: Group, in realm: Realm) -> Group {
        if let oldGroup = realm.object(ofType: Group.self, forPrimaryKey: newGroup.id) {
            newGroup.photos.append(objectsIn: oldGroup.photos)
            newGroup.posts.append(objectsIn: oldGroup.posts)
            newGroup.photosCount = newGroup.photosCount == -1 ? oldGroup.photosCount : newGroup.photosCount
            newGroup.postsCount = newGroup.postsCount == -1 ? oldGroup.postsCount : newGroup.postsCount
            return realm.create(Group.self, value: newGroup, update: .modified)
        } else {
            return realm.create(Group.self, value: newGroup)
        }
    }
    
    
    // MARK: - External methods -
    static func save(_ objects: Object?...) {
        let objects = objects.compactMap { $0 }
        guard let realm = realm() else { return }
        try? realm.write {
            objects.forEach { save($0, in: realm) }
        }
    }
    
    
    static func save<T: Object>(_ objects: [T]?, in list: List<T>?, completion: @escaping () -> Void = {}) {
        guard let objects = objects, let list = list else { return }
        let listReference = ThreadSafeReference(to: list)
        realmQueue.async {
            guard let realm = realm(), let list = realm.resolve(listReference) else { return }
            try? realm.write {
                if list.count != objects.count {
                    list.removeAll()
                }
                for object in objects {
                    let object = save(object, in: realm)
                    guard list.index(of: object) == nil else { continue }
                    list.append(object)
                }
                DispatchQueue.main.async {
                    guard let realm = self.realm() else { return }
                    realm.refresh()
                    completion()
                }
            }
        }
    }
    
    
    static func load<T: Object>(_ type: T.Type, with primaryKey: Int?) -> T? {
        realm()?.object(ofType: T.self, forPrimaryKey: primaryKey)
    }
    
    
    static func load<T: ThreadConfined>(with reference: ThreadSafeReference<T>) -> T? {
        realm()?.resolve(reference)
    }
    
    
    static func delete<T: Object & Identifiable>(_ objects: T...) {
        guard let realm = realm() else { return }
        try? realm.write {
            for object in objects {
                guard let object = realm.object(ofType: T.self, forPrimaryKey: object.id) else { continue }
                realm.delete(object)
            }
        }
    }
    
    
    static func create<T: Object & Identifiable>(_ object: T) -> T? {
        guard let realm = realm() else { return nil }
        return realm.object(ofType: T.self, forPrimaryKey: object.id) ?? {
            return try? realm.write {
                return realm.create(T.self, value: object)
            }
        }()
    }
    
    
    static func write(block: () -> Void) {
        try? realm()?.write {
            block()
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
