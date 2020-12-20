//
//  Response.swift
//  MyVK
//
//  Created by pgc6240 on 20.12.2020.
//

struct Response<I: Decodable>: Decodable {
    var response: Items<I>
}

struct Items<I: Decodable>: Decodable {
    var count: Int
    var items: [I]
}
