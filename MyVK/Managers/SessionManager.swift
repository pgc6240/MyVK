//
//  SessionManager.swift
//  MyVK
//
//  Created by pgc6240 on 17.12.2020.
//

import UIKit

enum SessionManager {
    
    static var loggingOut = false
    static var token: String!
    static var userId: Int!
    
    
    static func login(token: String?, userId: String?) {
        guard let token = token, let userId = Int(userId), let user = PersistenceManager.create(User(id: userId)) else {
            logout()
            return
        }
        
        self.token   = token
        self.userId  = userId
        
        User.current = user
        
        NetworkManager.shared.getUsers(userIds: [userId]) { users in
            guard let user = users.first else { return }
            PersistenceManager.save(user)
        }
        
        UIApplication.shared.windows.first?.rootViewController = UIStoryboard.main.instantiateInitialViewController()
    }
    
    
    static func logout() {
        loggingOut   = true
        token        = nil
        userId       = nil
        
        User.current = nil
        
        UIApplication.shared.windows.first?.rootViewController = LoginVC()
    }
}
