//
//  Photo.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

struct Photo: Decodable {
    
    let id: Int
    private let sizes: [Sizes]

    private struct Sizes: Decodable {
        let url: String
        let type: String
    }
    
    private enum Resolution: String, Comparable {
        case s, m, x, o, p, q, r, y, z, w
        
        static func < (lhs: Photo.Resolution, rhs: Photo.Resolution) -> Bool {
            switch lhs {
            case .s:
                return true
            case .w:
                return false
            default:
                return lhs.rawValue < rhs.rawValue
            }
        }
    }
    
    var url: String? {
        let maxSize = sizes.sorted { Resolution(rawValue: $0.type)! > Resolution(rawValue: $1.type)! }.first
        return maxSize?.url
    }
}
