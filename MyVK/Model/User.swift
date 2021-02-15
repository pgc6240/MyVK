//
//  User.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation
import RealmSwift

final class User: Object, CanPost, Identifiable {
    
    @objc dynamic var id = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var photoUrl = ""
    @objc dynamic var firstNameGen = "" // Gen - genetivus
    @objc dynamic var lastNameGen = ""
    @objc dynamic var lastNameFirstLetter: String? = nil
    @objc dynamic var canAccessClosed = false
    @objc dynamic var homeTown: String? = nil
    @objc dynamic var bdate: String? = nil
    @objc dynamic var friendsCount = 0
    @objc dynamic var groupsCount = 0
    @objc dynamic var photosCount = 0
    @objc dynamic var postsCount = 0
    let friends = List<User>()
    let groups = List<Group>()
    let photos = List<Photo>()
    let posts = List<Post>()
    
    
    // MARK: - Realm Object's methods -
    override class func primaryKey() -> String? { "id" }
}


// MARK: - Computed properties -
extension User {

    var name: String    { firstName    + " " + lastName }
    var nameGen: String { firstNameGen + " " + lastNameGen }
    var age: String? {
        guard let byear = Int(bdate?.components(separatedBy: ".").first { $0.count == 4 }) else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date())
        return "\(currentYear - byear) \("лет".localized)"
    }
}


// MARK: - Current user -
extension User {
    
    static var current: User {
        get { PersistenceManager.load(User.self, with: SessionManager.userId) ?? createCurrentUser() }
        set { PersistenceManager.save(newValue) }
    }
    
    
    private convenience init(id: Int) {
        self.init()
        self.id = id
    }
    
    
    private static func createCurrentUser() -> User {
        NetworkManager.shared.getUsers(userIds: [SessionManager.userId]) { users in
            PersistenceManager.save(users.first)
        }
        return PersistenceManager.create(User(id: SessionManager.userId))
    }
}


// MARK: - Decodable -
extension User: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, photoUrl = "photoMax", firstNameGen, lastNameGen, homeTown, bdate, canAccessClosed
        case counters, photos, friends, pages, groups
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
        self.lastNameFirstLetter = self.lastName.first.toString
        if let countersContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .counters) {
            self.friendsCount = (try? countersContainer.decode(Int.self, forKey: .friends)) ?? 0
            let groups = (try? countersContainer.decode(Int.self, forKey: .groups)) ?? 0
            let pages = (try? countersContainer.decode(Int.self, forKey: .pages)) ?? 0
            self.groupsCount = groups + pages
            self.photosCount = (try? countersContainer.decode(Int.self, forKey: .photos)) ?? 0
        }
    }
}
