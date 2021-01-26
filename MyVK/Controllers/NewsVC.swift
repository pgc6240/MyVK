//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit
import RealmSwift

final class NewsVC: UIViewController {
    
    var token: NotificationToken?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = User.current.name
        token = User.current.observe { [weak self] _ in
            self?.navigationItem.title = User.current.name
        }
    }
    
    
    @IBAction func logoutButtonTapped() {
        SessionManager.logout()
    }
}
