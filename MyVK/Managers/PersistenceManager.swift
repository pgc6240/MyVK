//
//  PersistenceManager.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import RealmSwift
import UIKit

enum PersistenceManager {
    
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
        configuration.objectTypes = [User.self, Group.self, Photo.self, Post.self]
        configuration.deleteRealmIfMigrationNeeded = true
        return configuration
    }()
    
    private static let realmQueue = DispatchQueue(label: "com.pgc6240.MyVK.realmQueue", attributes: .concurrent)
    
    private static var notificationTokens = [ObjectIdentifier?: NotificationToken?]()
}


// MARK: - Internal methods -
private extension PersistenceManager {

    @discardableResult
    static func save<T: Object>(_ object: T, in realm: Realm) -> T {
        if let user = object as? User {
            return save(user, in: realm) as! T
        } else if let group = object as? Group {
            return save(group, in: realm) as! T
        } else if let post = object as? Post {
            return save(post, in: realm) as! T
        } else {
            return realm.create(T.self, value: object, update: .modified)
        }
    }
    
    
    @discardableResult
    static func save(_ newUser: User, in realm: Realm) -> User {
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
    static func save(_ newGroup: Group, in realm: Realm) -> Group {
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
    
    
    @discardableResult
    static func save(_ newPost: Post, in realm: Realm) -> Post {
        if let userOwner = realm.object(ofType: User.self, forPrimaryKey: newPost.sourceId) {
            newPost.userOwner = userOwner
        } else if let groupOwner = realm.object(ofType: Group.self, forPrimaryKey: -newPost.sourceId) {
            newPost.groupOwner = groupOwner
        }
        return realm.create(Post.self, value: newPost, update: .modified)
    }
}
    
    
// MARK: - External methods -
extension PersistenceManager {
    
    static func create<T: Object & Identifiable>(_ object: T) -> T? {
        realmQueue.sync {
            guard let realm = realm() else { return nil }
            return realm.object(ofType: T.self, forPrimaryKey: object.id) ?? {
                return try? realm.write {
                    return realm.create(T.self, value: object, update: .modified)
                }
            }()
        }
    }
    

    static func save(_ objects: Object?..., completion: @escaping () -> Void = {}) {
        guard let realm = realm() else { return }
        let objects = objects.compactMap { $0 }
        try? realm.write {
            objects.forEach { save($0, in: realm) }
            DispatchQueue.main.async {
                guard let realm = self.realm() else { return }
                realm.refresh()
                completion()
            }
        }
    }
    
    
    static func save<T: Object>(_ objects: [T]?, in list: List<T>?, completion: @escaping () -> Void = {}) {
        guard let objects = objects, let list = list else { return }
        let listReference = ThreadSafeReference(to: list)
        let workItem = DispatchWorkItem(qos: .userInteractive, flags: .barrier) {
            guard let realm = realm(), let list = realm.resolve(listReference) else { return }
            try? realm.write {
                if objects.count != list.count {
                    list.removeAll()
                }
                for object in objects {
                    let object = save(object, in: realm)
                    guard list.index(of: object) == nil else { continue }
                    list.append(object)
                }
            }
        }
        realmQueue.async(execute: workItem)
        workItem.notify(queue: .main) {
            guard let realm = realm() else { return }
            realm.refresh()
            completion()
        }
    }
    
    
    static func write(block: () -> Void) {
        guard let realm = realm() else { return }
        try? realm.write {
            block()
        }
    }
    
    
    static func load<T: Object>(_ type: T.Type, with primaryKey: Int?) -> T? {
        guard let realm = realm() else { return nil }
        return realm.object(ofType: T.self, forPrimaryKey: primaryKey)
    }
    
    
    static func load<T: ThreadConfined>(with reference: ThreadSafeReference<T>) -> T? {
        guard let realm = realm() else { return nil }
        return realm.resolve(reference)
    }
    
    
    static func delete<T: Object & Identifiable>(_ object: T) {
        guard let realm = realm(), let object = realm.object(ofType: T.self, forPrimaryKey: object.id) else { return }
        try? realm.write {
            realm.delete(object)
        }
    }
}
    
 
// MARK: - Realm Notifications -
extension PersistenceManager {

    static func pair<T: Object>(_ objects: List<T>?, with tableView: UITableView?, onChange: @escaping () -> Void = {}) {
        let token = objects?.observe { [weak tableView] changes in
            switch changes {
            case .initial(_):
                onChange()
                tableView?.reloadData()
            case .update(let updatedObjects, let deletions, let insertions, let modifications):
                onChange()
                if updatedObjects.isEmpty || updatedObjects.count == insertions.count {
                    tableView?.reloadSections([0], with: .automatic)
                } else {
                    tableView?.beginUpdates()
                    tableView?.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .left)
                    tableView?.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    tableView?.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    tableView?.endUpdates()
                }
            case .error(let error):
                fatalError("\(error)")
            }
        }
        notificationTokens[tableView?.id] = token
    }
    
    
    static func unpair(_ tableView: UITableView?) {
        notificationTokens[tableView?.id]??.invalidate()
        notificationTokens[tableView?.id] = nil
    }
}
