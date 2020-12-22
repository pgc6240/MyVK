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
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LoginVC()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        coder.encode(PersistenceManager.appVersion, forKey: PersistenceManager.Keys.appVersion)
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        return coder.decodeObject(forKey: PersistenceManager.Keys.appVersion) as? String == PersistenceManager.appVersion
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        PersistenceManager.save()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        PersistenceManager.load()
    }
}


//
// MARK: - Dummy data
//
//let somePhotos = [Photo(imageName: "photo-1"), Photo(imageName: "photo-2"), Photo(imageName: "photo-1")]

//let somePosts: [Post] = [
//    Post(text: "Какой-то очень интересный пост.", photos: somePhotos, likeCount: 50, viewCount: 697),
//    Post(text: "Ещё более интересный пост.", photos: somePhotos.dropLast(), likeCount: 107, viewCount: 1012),
//    Post(text: "Не очень интересный пост.", photos: [somePhotos[1]], likeCount: 25, viewCount: 273)
//]
