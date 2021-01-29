//
//  Photo.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit
import RealmSwift

final class Photo: Object, Identifiable {
    
    @objc dynamic var id = 0
    @objc dynamic var maxSizeUrl: String? = nil
    @objc private dynamic var _width = 0
    @objc private dynamic var _height = 0
    var width: CGFloat { CGFloat(_width) }
    var height: CGFloat { CGFloat(_height) }
    
    
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
        guard let paramaters = maxSizeUrl?.toUrl.parameters else { return }
        let size = paramaters["size"]?.components(separatedBy: "x")
        let width = size?.first
        let height = size?.last
        self._width = Int(width) ?? 0
        self._height = Int(height) ?? 0
    }
}
