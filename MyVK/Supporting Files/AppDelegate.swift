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
        return true
    }
    
    
    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        PersistenceManager.save()
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        PersistenceManager.load()
    }
}

