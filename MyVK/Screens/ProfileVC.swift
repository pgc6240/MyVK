//
//  ProfileVC.swift
//  MyVK
//
//  Created by pgc6240 on 10.02.2021.
//

import UIKit
import Combine
import RealmSwift

class ProfileVC: UIViewController {
    
    var owner: CanPost = User.current
    
    lazy var postsVC = children.first as? PostsVC
    var getProfileDetailsTask: AnyCancellable?
    
    // MARK: - Subviews
    @IBOutlet weak var profileHeaderView: ProfileHeaderView!
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        postsVC?.set(with: owner, and: profileHeaderView)
        profileHeaderView.set(with: owner)
        getProfileDetails()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        getProfileDetailsTask?.cancel()
    }
    
    
    // MARK: - External methods -
    func getProfileDetails() {
        if owner.posts.isEmpty {
            showLoadingView()
        }
        if let user = owner as? User {
            getProfileDetailsForUser(user)
        } else if let group = owner as? Group {
            getProfileDetailsForGroup(group)
        }
    }
    
    
    func getProfileDetailsForUser(_ user: User) {
        if !user.friends.isEmpty {
            prepareFriendsVC(with: user.friends)
        }
        getProfileDetailsTask = NetworkManager.shared.getFriendsGroupsPhotosAndPosts(for: user.id) {
            [weak self] friends, groups, photos, posts in
            PersistenceManager.save(friends, in: user.friends)
            PersistenceManager.save(groups, in: user.groups)
            PersistenceManager.save(photos, in: user.photos)
            PersistenceManager.save(posts, in: user.posts)
            self?.profileHeaderView.set(with: user)
            self?.dismissLoadingView()
            self?.prepareFriendsVC(with: user.friends)
        }
    }
    
    
    func getProfileDetailsForGroup(_ group: Group) {
        getProfileDetailsTask = NetworkManager.shared.getMembersPhotosAndPostsCount(for: group.id) {
            [weak self] membercount, photosCount, postsCount in
            self?.profileHeaderView.set(membercount, photosCount, postsCount)
            self?.dismissLoadingView()
        }
    }
    
    
    // MARK: - Internal methods -
    @IBAction func postsButtonTapped() {
        guard (postsVC?.posts.count ?? 0) > 0 else { return }
        postsVC?.tableView.scrollToRow(at: [0,0], at: .top, animated: true)
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
        case .toFriends:
            let friendsVC                    = (segue.destination as? FriendsVC)
            friendsVC?.user                  = owner as? User
            guard !numberOfRowsInSection.isEmpty else { return }
            friendsVC?.availableLetters      = availableLetters
            friendsVC?.numberOfRowsInSection = numberOfRowsInSection
        case .toGroups: (segue.destination as? GroupsVC)?.user = owner as? User
        case .toPhotos: (segue.destination as? PhotosVC)?.owner = owner
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard (sender as? UIButton)?.currentTitle != "0" else { return false }
        return true
    }
    
    
    // MARK: - Prepare for segue to FriendsVC -
    private var availableLetters = [String]()
    private var numberOfRowsInSection: [Int: Int] = [:]
    
    
    private func prepareFriendsVC(with friends: List<User>) {
        guard numberOfRowsInSection.isEmpty && owner !== User.current else { return }
        let operation1 = UpdateAvailableLettersOperation(with: ThreadSafeReference(to: friends))
        let operation2 = CalculateNumberOfRowsInSectionForFriendsVCOperation()
        operation2.addDependency(operation1)
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.addOperations([operation1, operation2], waitUntilFinished: false)
        operation1.completionBlock = { [weak self] in self?.availableLetters = operation1.availableLetters }
        operation2.completionBlock = { [weak self] in self?.numberOfRowsInSection = operation2.numberOfRowsInSection }
    }
}
