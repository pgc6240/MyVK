//
//  User.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation
import RealmSwift

protocol CanPost {
    var id: Int { get }
    var name: String { get }
    var photoUrl: String { get }
    var posts: List<Post> { get }
}

final class User: Object, CanPost {
    
    var name: String { firstName + " " + lastName }
    @objc dynamic var id = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var photoUrl = ""
    let friends = List<User>()
    let photos = List<Photo>()
    let groups = List<Group>()
    let posts = List<Post>()
    
    
    //MARK: - Realm Object's methods -
    override class func primaryKey() -> String? { "id" }
    
    
    //MARK: - Current user -
    static var current: User!
    
    static func setCurrentUser(with id: Int) {
        if let userStored = PersistenceManager.load(User.self, with: id) {
            User.current = userStored
        } else {
            User.current = PersistenceManager.create(User(id: id))
            NetworkManager.shared.getUsers(userIds: [id]) { users in
                guard let currentUser = users.first else { return }
                PersistenceManager.save(currentUser)
            }
        }
    }
    
    convenience init(id: Int) {
        self.init()
        self.id = id
    }
}


//
// MARK: - Decodable -
//
extension User: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, photoUrl = "photoMax"
    }
}
