//
//  Photo.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

struct Photo: Decodable {
    
    let id: Int
    let sizes: [Sizes]

    struct Sizes: Decodable {
        let url: String
        let width: Int
        let height: Int
    }
    
    var url: String? {
        let maxSize = sizes.sorted { max($0.width, $0.height) > max($1.width, $1.height) }.first
        return maxSize?.url
    }
}
