//
//  User.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation
import RealmSwift

protocol CanPost: class {
    var id: Int { get }
    var name: String { get }
    var photoUrl: String { get }
    var posts: List<Post> { get }
    var photos: List<Photo> { get }
}

final class User: Object, CanPost, Identifiable {
    
    // MARK: - Realm persisted properties -
    @objc dynamic var id = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var firstNameGen = "" /* Gen - genetivus */
    @objc dynamic var lastNameGen = ""
    @objc dynamic var photoUrl = ""
    @objc dynamic var homeTown: String? = nil
    @objc dynamic var bdate: String? = nil
    @objc dynamic var canAccessClosed = false
    let friends = List<User>()
    let photos = List<Photo>()
    let groups = List<Group>()
    let posts = List<Post>()
    
    
    // MARK: - Computed properties -
    var name: String { firstName + " " + lastName }
    var nameGen: String { firstNameGen + " " + lastNameGen }
    @objc var lastNameLatin: String { lastName.toLatin }
    var age: String? {
        guard let bdate = bdate else { return nil }
        guard let byear = Int(bdate.components(separatedBy: ".").first { $0.count == 4 }) else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date())
        return "\(currentYear - byear) \("лет".localized)"
    }
    
    
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
        case id, firstName, lastName, photoUrl = "photoMax", firstNameGen, lastNameGen, homeTown, bdate, canAccessClosed
    }
    
    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.photoUrl = try container.decode(String.self, forKey: .photoUrl)
        self.firstNameGen = try container.decode(String.self, forKey: .firstNameGen)
        self.lastNameGen = try container.decode(String.self, forKey: .lastNameGen)
        self.homeTown = try? container.decode(String.self, forKey: .homeTown)
        self.bdate = try? container.decode(String.self, forKey: .bdate)
        self.canAccessClosed = (try? container.decode(Bool.self, forKey: .canAccessClosed)) ?? false
    }
}
