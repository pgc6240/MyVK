//
//  SessionManager.swift
//  MyVK
//
//  Created by pgc6240 on 17.12.2020.
//

import UIKit

enum SessionManager {
    
    static var token: String?
    static var userId: Int?
    
    
    static func login(token: String?, usedId: String?) {
        SessionManager.token  = token
        SessionManager.userId = Int(usedId)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        UIApplication.shared.windows.first?.rootViewController = storyboard.instantiateInitialViewController()
    }
    
    
    static func logout() {
        SessionManager.token  = nil
        SessionManager.userId = nil
        
        UIApplication.shared.windows.first?.rootViewController = LoginVC()
    }
}
