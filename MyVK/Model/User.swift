//
//  User.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation

struct Response: Decodable {
    var response: Users
}

struct Users: Decodable {
    var items: [User] = []
}


final class User: Decodable {
    
    @objc var firstName = ""
    @objc var lastName  = ""
    
    
    init(firstName: String, lastName: String) {
        self.firstName  = firstName
        self.lastName   = lastName
    }
}
