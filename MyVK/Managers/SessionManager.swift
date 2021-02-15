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
        guard token != nil, userId != nil else {
            logout()
            return
        }
        self.token  = token
        self.userId = Int(userId)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        UIApplication.shared.windows.first?.rootViewController = storyboard.instantiateInitialViewController()
    }
    
    
    static func logout() {
        loggingOut  = true
        token       = nil
        userId      = nil
        
        UIApplication.shared.windows.first?.rootViewController = LoginVC()
    }
}
