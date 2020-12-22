//
//  User.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation

final class User: Decodable {
    
    let id: Int
    @objc let firstName: String
    @objc let lastName: String
}
