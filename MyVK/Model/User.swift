//
//  User.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import Foundation
import RealmSwift

final class User: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var photoMax = ""
    let photos = List<Photo>()
    
    
    override class func primaryKey() -> String? { "id" }
}


//
// MARK: - Decodable
//
extension User: Decodable {
    
    private enum CodingKeys: CodingKey {
        case id, firstName, lastName, photoMax
    }
}
