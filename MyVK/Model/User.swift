//
//  User.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation

final class User: Decodable {
    
    let id: Int
    @objc var firstName: String
    @objc var lastName: String
    let photoMax: String
}
