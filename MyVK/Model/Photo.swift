//
//  Photo.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

struct Photo: Decodable {
    var id: Int
    var sizes: [Sizes]
    
    struct Sizes: Decodable {
        var url: String
    }
}
