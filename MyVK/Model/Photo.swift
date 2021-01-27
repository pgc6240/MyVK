//
//  Photo.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import Foundation
import RealmSwift

final class Photo: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var maxSizeUrl: String? = nil
    
    
    override class func primaryKey() -> String? { "id" }
}


//
// MARK: - Photo sizes -
//
fileprivate struct Size: Decodable, Comparable {
    let url: String
    let type: String
    
    static func < (lhs: Size, rhs: Size) -> Bool {
        switch (lhs.type, rhs.type) {
        case ("s", _), (_, "w"): /* s - min resolution, w - max resolution */
            return true
        case (_, "s"), ("w", _):
            return false
        default:
            return lhs.type < rhs.type
        }
    }
}


//
// MARK: - Decodable -
//
extension Photo: Decodable {
    
    private enum CodingKeys: CodingKey {
        case id, sizes
    }
    
    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        let sizes = try container.decode([Size].self, forKey: .sizes)
        self.maxSizeUrl = sizes.max()?.url
    }
}
