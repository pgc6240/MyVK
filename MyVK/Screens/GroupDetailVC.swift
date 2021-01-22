//
//  GroupDetailVC.swift
//  MyVK
//
//  Created by pgc6240 on 22.01.2021.
//

import UIKit

final class GroupDetailVC: UIViewController {
    
    var group: Group!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = group.name
        let postListVC = children.first as? PostListVC
        postListVC?.set(with: group.posts, and: -group.id)
    }
}
