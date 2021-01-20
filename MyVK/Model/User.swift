//
//  User.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation
import RealmSwift

final class User: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var maxSizePhotoUrl = ""
    let photos = LinkingObjects(fromType: Photo.self, property: "owner")
    let groups = List<Group>()
    
    
    //MARK: - Current user
    static var current: User!
    
    convenience init(id: Int) {
        self.init()
        self.id = id
    }
    
    static func setCurrentUser(id: Int) {
        if let userStored = PersistenceManager.load(User.self, with: id) {
            User.current = userStored
        } else {
            User.current = User(id: id)
            PersistenceManager.save([User.current])
        }
    }
    
    
    //MARK: - Realm Object's methods
    override class func primaryKey() -> String? { "id" }
}


//
// MARK: - Decodable
//
extension User: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, maxSizePhotoUrl = "photoMax"
    }
}
