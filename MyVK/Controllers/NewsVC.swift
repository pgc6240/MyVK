//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class NewsVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = User.current.name
    }
    
    
    @IBAction func logoutButtonTapped() {
        SessionManager.logout()
    }
}
