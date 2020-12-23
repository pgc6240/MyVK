//
//  Photo.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class Photo: Decodable {
    
    let id: Int
    fileprivate let sizes: [Resolution]
    var url: String? { sizes.max()?.url }
}


fileprivate struct Resolution: Decodable, Comparable {
    let url: String
    let type: String
    
    static func < (lhs: Resolution, rhs: Resolution) -> Bool {
        switch lhs.type {
        case "s": /* min resolution */
            return true
        case "w": /* max resolution */
            return false
        default:
            return lhs.type < rhs.type
        }
    }
}
