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
        configuration.objectTypes = [User.self, Group.self, Photo.self, Post.self, Attachment.self]
        return configuration
    }()
    
    
    static func save(_ objects: Object...) {
        let realm = try? Realm(configuration: realmConfiguration)
        try? realm?.write {
            realm?.add(objects, update: .modified)
        }
    }
    
    
    static func save<T: Object>(_ objects: [T], in list: List<T>) {
        guard let realm = try? Realm(configuration: realmConfiguration) else { return }
        try? realm.write {
            if list.count > objects.count {
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
                    realm.add(newUser, update: .modified)
                    
                } else if let newGroup = newObject as? Group,
                          let oldGroup = realm.object(ofType: Group.self, forPrimaryKey: newGroup.id)
                {
                    newGroup.posts.append(objectsIn: oldGroup.posts)
                    realm.add(newGroup, update: .modified)
                    
                } else {
                    let newObject = realm.create(T.self, value: newObject, update: .modified)
                    guard !list.contains(newObject) else { return }
                    list.append(newObject)
                }
            }
        }
    }
    
    
    static func load<T: Object>(_ type: T.Type, with primaryKey: Int) -> T? {
        let realm = try? Realm(configuration: realmConfiguration); print(realm?.configuration.fileURL ?? "")
        return realm?.object(ofType: T.self, forPrimaryKey: primaryKey)
    }
    
    
    static func delete(_ objects: Object...) {
        DispatchQueue.main.async {
            let realm = try? Realm(configuration: realmConfiguration)
            try? realm?.write {
                realm?.delete(objects)
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
