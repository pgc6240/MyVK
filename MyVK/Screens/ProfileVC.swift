//
//  ProfileVC.swift
//  MyVK
//
//  Created by pgc6240 on 10.02.2021.
//

import UIKit

class ProfileVC: UIViewController {
    
    var owner: CanPost = User.current
    
    lazy var postsVC = children.first as! PostsVC
    
    // MARK: - Subviews
    @IBOutlet weak var profileHeaderView: ProfileHeaderView!
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        postsVC.set(with: owner, and: profileHeaderView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        getProfileDetails()
    }
    
    
    // MARK: - External methods -
    func getProfileDetails() {
        if let user = owner as? User {
            getProfileDetailsForUser(user)
        } else if let group = owner as? Group {
            getProfileDetailsForGroup(group)
        }
    }
    
    
    func getProfileDetailsForUser(_ user: User) {
        NetworkManager.shared.getUsers(userIds: [owner.id]) { [weak self] users in
            guard let user = users.first else { return }
            PersistenceManager.save(user)
            self?.profileHeaderView.set(with: user)
        }
    }
    
    
    func getProfileDetailsForGroup(_ group: Group) {
        NetworkManager.shared.getGroups(groupIds: [owner.id]) { [weak self] (groups) in
            guard let group = groups.first else { return }
            PersistenceManager.save(group)
            self?.profileHeaderView.set(with: group)
        }
    }
    
    
    // MARK: - Internal methods -
    @IBAction func postsButtonTapped() {
        guard !postsVC.posts.isEmpty else { return }
        postsVC.tableView.scrollToRow(at: [0,0], at: .top, animated: true)
    }
    
    
    // MARK: - Segues -
    private enum SegueIdentifier: String {
        case toFriends
        case toGroups
        case toPhotos
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = SegueIdentifier(rawValue: segue.identifier ?? "") else { return }
        switch segueIdentifier {
        case .toFriends: (segue.destination as? FriendsVC)?.user = owner as? User
        case .toGroups: (segue.destination as? GroupsVC)?.user = owner as? User
        case .toPhotos: (segue.destination as? PhotosVC)?.owner = owner
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard (sender as? UIButton)?.currentTitle != "0" else { return false }
        return !profileHeaderView.groupsStackView.isHidden || identifier == "toPhotos"
    }
}
