//
//  Photo.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit
import RealmSwift

final class Photo: Object, Decodable {
    
    @objc dynamic var id: Int
    fileprivate let sizes: [Resolution]
    var maxSizeUrl: String? { sizes.max()?.url }
    
    override class func primaryKey() -> String? { "id" }
}


fileprivate struct Resolution: Decodable, Comparable {
    let url: String
    let type: String
    
    static func < (lhs: Resolution, rhs: Resolution) -> Bool {
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
