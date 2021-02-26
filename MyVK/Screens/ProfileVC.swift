//
//  ProfileVC.swift
//  MyVK
//
//  Created by pgc6240 on 10.02.2021.
//

import UIKit
import RealmSwift

class ProfileVC: UIViewController {
    
    var owner: CanPost = User.current
    
    lazy var postsVC = children.first as! PostsVC
    weak var selectedPost: Post!
    
    // MARK: - Subviews
    @IBOutlet weak var profileHeaderView: ProfileHeaderView!
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        postsVC.owner = owner
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
            prepareFriendsVC(for: user)
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
        case fromPostToPhotos
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = SegueIdentifier(rawValue: segue.identifier ?? "") else { return }
        switch segueIdentifier {
        case .toFriends:
            (segue.destination as? FriendsVC)?.user = owner as? User
            preparationQueue.cancelAllOperations()
            postsVC.cleanUp()
        case .toGroups: (segue.destination as? GroupsVC)?.user = owner as? User
        case .toPhotos: (segue.destination as? PhotosVC)?.owner = owner
        case .fromPostToPhotos: (segue.destination as? PhotosVC)?.post = PersistenceManager.create(selectedPost)
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toPostPhotos" { return true }
        guard (sender as? UIButton)?.currentTitle != "0" else { return false }
        return !profileHeaderView.groupsStackView.isHidden || identifier == "toPhotos"
    }
    
    
    // MARK: - Prepare FriendsVC operation -
    var availableLetters = [String]()
    var numberOfRowsInSection = [Int: Int]()
    private let preparationQueue = OperationQueue()
    
    
    func prepareFriendsVC(for user: User) {
        guard numberOfRowsInSection.isEmpty else { return }
        let prepareFriendsVCOperation = PrepareFriendsVCOperation(for: user)
        prepareFriendsVCOperation.completionBlock = { [weak self] in
            self?.availableLetters      = prepareFriendsVCOperation.availableLetters
            self?.numberOfRowsInSection = prepareFriendsVCOperation.numberOfRowsInSection
        }
        preparationQueue.qualityOfService = .userInteractive
        preparationQueue.addOperation(prepareFriendsVCOperation)
    }
}


//
// MARK: - PostCellDelegate -
//
extension ProfileVC: PostCellDelegate {
    
    func photoTapped(on post: Post) {
        selectedPost = post
        performSegue(withIdentifier: SegueIdentifier.fromPostToPhotos.rawValue, sender: nil)
    }
    
    
    @objc func deletePost(postId: Int) {}
}
