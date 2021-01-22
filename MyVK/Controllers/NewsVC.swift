//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class NewsVC: UIViewController {
    
    @IBAction func logoutButtonTapped() {
        SessionManager.logout()
    }
}
