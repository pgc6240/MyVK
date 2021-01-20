//
//  Post.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import Foundation
import RealmSwift

final class Post: Object, Decodable {

    @objc dynamic var id = 0
    @objc dynamic var text = ""
    
    
    override class func primaryKey() -> String? { "id" }
}
