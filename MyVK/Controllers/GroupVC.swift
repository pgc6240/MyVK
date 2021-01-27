//
//  GroupVC.swift
//  MyVK
//
//  Created by pgc6240 on 22.01.2021.
//

import UIKit

final class GroupVC: UIViewController {
    
    var group: Group!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    
    private func configureViewController() {
        title = group.name
        (children.first as? PostsVC)?.set(with: group)
    }
}
