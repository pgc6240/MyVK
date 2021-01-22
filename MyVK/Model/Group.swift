//
//  Group.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation
import RealmSwift

final class Group: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var isOpen = false
    @objc dynamic var isMember = false
    @objc dynamic var photoUrl = ""
    let posts = List<Post>()
    

    override class func primaryKey() -> String? { "id" }
}


//
// MARK: - Decodable
//
extension Group: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id, name, isClosed, isMember, photoUrl = "photo200"
    }
    
    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        let isClosed = try container.decode(Int.self, forKey: .isClosed)
        self.isOpen = isClosed == 0
        let isMember = try container.decode(Int.self, forKey: .isMember)
        self.isMember = isMember == 1
        self.photoUrl = try container.decode(String.self, forKey: .photoUrl)
    }
}
