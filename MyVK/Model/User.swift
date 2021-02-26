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
    @objc dynamic var name = ""
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var photoUrl = ""
    @objc dynamic var nameGen = ""
    @objc dynamic var firstNameGen = "" // Gen - genetivus
    @objc dynamic var lastNameGen = ""
    @objc dynamic var lastNameFirstLetter: String? = nil
    @objc dynamic var canAccessClosed = false
    @objc dynamic var canSendFriendRequest = false
    @objc dynamic var isFriend = false
    @objc dynamic var homeTown: String? = nil
    @objc dynamic var bdate: String? = nil
    @objc dynamic var age: String? = nil
    @objc dynamic var secondaryText: String? = nil
    @objc dynamic var friendsCount = -1
    @objc dynamic var groupsCount = -1
    @objc dynamic var photosCount = -1
    @objc dynamic var postsCount = -1
    let friends = List<User>()
    let groups = List<Group>()
    let photos = List<Photo>()
    let posts = List<Post>()
    
    
    override class func primaryKey() -> String? { "id" }
    override class func indexedProperties() -> [String] { ["lastNameFirstLetter", "firstName", "lastName"] }
}


// MARK: - Computed properties -
extension User {

    private var _age: String? {
        guard let byear = Int(bdate?.components(separatedBy: ".").first { $0.count == 4 }) else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date())
        return "\(currentYear - byear) \("лет".localized)"
    }
    
    private var _secondaryText: String? {
        canAccessClosed ? (homeTown ?? age) : "Закрытый профиль".localized
    }
}


// MARK: - Current user -
extension User {
    
    static var current: User!
    
    
    convenience init(id: Int) {
        self.init()
        self.id = id
    }
}


// MARK: - Decodable -
extension User: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, photoUrl = "photoMax", firstNameGen, lastNameGen, homeTown, bdate, canAccessClosed
        case counters, photos, friends, pages, groups
        case canSendFriendRequest, isFriend = "friendStatus"
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
        let canSendFriendRequest = (try? container.decode(Int.self, forKey: .canSendFriendRequest)) ?? 0
        self.canSendFriendRequest = canSendFriendRequest == 1
        let isFriend = (try? container.decode(Int.self, forKey: .isFriend)) ?? 0
        self.isFriend = isFriend != 0
        self.lastNameFirstLetter = self.lastName.first.toString
        if let countersContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .counters) {
            self.friendsCount = (try? countersContainer.decode(Int.self, forKey: .friends)) ?? 0
            let groups = (try? countersContainer.decode(Int.self, forKey: .groups)) ?? 0
            let pages = (try? countersContainer.decode(Int.self, forKey: .pages)) ?? 0
            self.groupsCount = groups + pages
            self.photosCount = (try? countersContainer.decode(Int.self, forKey: .photos)) ?? 0
        }
        self.name = "\(firstName) \(lastName)"
        self.nameGen = "\(firstNameGen) \(lastNameGen)"
        self.age = _age
        self.secondaryText = _secondaryText
    }
}
