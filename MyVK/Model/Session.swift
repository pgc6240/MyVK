//
//  Session.swift
//  MyVK
//
//  Created by pgc6240 on 17.12.2020.
//

final class Session {
    
    static let shared = Session()
    
    private init() {}
    
    var token: String?
    var userId: Int?
}
