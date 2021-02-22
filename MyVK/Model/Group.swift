//
//  Group.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation
import RealmSwift

final class Group: Object, CanPost, Identifiable {
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var isOpen = false
    @objc dynamic var isMember = false
    @objc dynamic var photoUrl = ""
    @objc dynamic var city: String? = nil
    @objc dynamic var membersCount = -1
    @objc dynamic var photosCount = -1
    @objc dynamic var postsCount = -1
    let photos = List<Photo>()
    let posts = List<Post>()
    

    override class func primaryKey() -> String? { "id" }
    override class func indexedProperties() -> [String] { ["name"] }
}


//
// MARK: - Decodable -
//
extension Group: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id, name, isClosed, isMember, photoUrl = "photo200", city, title, photoMax
        case counters, photos, membersCount
    }
    
    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        let isClosed = try container.decode(Int.self, forKey: .isClosed)
        self.isOpen = isClosed == 0
        let isMember = try? container.decode(Int.self, forKey: .isMember)
        self.isMember = isMember == 1
        do {
            self.photoUrl = try container.decode(String.self, forKey: .photoUrl)
        } catch {
            self.photoUrl = try container.decode(String.self, forKey: .photoMax)
        }
        if let cityContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .city) {
            self.city = try? cityContainer.decode(String.self, forKey: .title)
        }
        self.membersCount = (try? container.decode(Int.self, forKey: .membersCount)) ?? -1
        if let countersContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .counters) {
            self.photosCount = (try? countersContainer.decode(Int.self, forKey: .photos)) ?? 0
        }
    }
}
