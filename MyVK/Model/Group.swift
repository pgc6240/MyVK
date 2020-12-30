//
//  Group.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation
import RealmSwift

final class Group: Object, Decodable {
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var isOpen = false
    @objc dynamic var isMember = false
    
    private enum CodingKeys: CodingKey {
        case id, name, isClosed, isMember
    }
    
    
    override class func primaryKey() -> String? { "id" }
    
    override init() { super.init() }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        let isClosed = try container.decode(Int.self, forKey: .isClosed)
        self.isOpen = isClosed == 0
        let isMember = try container.decode(Int.self, forKey: .isMember)
        self.isMember = isMember == 1
    }
}
