//
//  SessionManager.swift
//  MyVK
//
//  Created by pgc6240 on 17.12.2020.
//

import UIKit

enum SessionManager {
    
    static var loggingOut = false
    static var token: String?
    
    
    static func login(token: String?, userId: String?) {
        self.token = token
        
        if let userId = Int(userId) {
            User.setCurrentUser(with: userId)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        UIApplication.shared.windows.first?.rootViewController = storyboard.instantiateInitialViewController()
    }
    
    
    static func logout() {
        SessionManager.loggingOut = true
        SessionManager.token = nil
        User.current = nil
        
        UIApplication.shared.windows.first?.rootViewController = LoginVC()
    }
}
