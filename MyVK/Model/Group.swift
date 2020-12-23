//
//  Group.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

final class Group: Decodable {
    
    let id: Int
    let name: String
    let isOpen: Bool
    var isMember: Bool
    
    private enum CodingKeys: CodingKey {
        case id, name, isClosed, isMember
    }
    
    
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
