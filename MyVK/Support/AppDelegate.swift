//
//  AppDelegate.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        coder.encode(PersistenceManager.appVersion, forKey: PersistenceManager.Keys.appVersion)
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        return coder.decodeObject(forKey: PersistenceManager.Keys.appVersion) as? String == PersistenceManager.appVersion
    }
}
