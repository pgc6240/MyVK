//
//  UserDetailVC.swift
//  MyVK
//
//  Created by pgc6240 on 10.02.2021.
//

import UIKit
import Combine

final class UserDetailVC: UIViewController {
    
    var user: User! = User.current
    
    private var getUserDetailsTask: AnyCancellable?
    private lazy var postsVC = children.first as? PostsVC
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        postsVC?.set(with: user)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserDetails()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        getUserDetailsTask?.cancel()
    }
    
    
    // MARK: - External methods -
    func getUserDetails() {
        if user.friends.isEmpty {
            showLoadingView()
        }
        getUserDetailsTask = NetworkManager.shared.getFriendsGroupsPhotosAndPosts(for: user.id) {
            [weak self] friends, groups, photos, posts in
            self?.dismissLoadingView()
            PersistenceManager.save(friends, in: self?.user.friends)
            PersistenceManager.save(groups, in: self?.user.groups)
            PersistenceManager.save(photos, in: self?.user.photos)
            PersistenceManager.save(posts, in: self?.user.posts)
            self?.postsVC?.profileHeaderView.set(with: self?.user)
        }
    }
}
