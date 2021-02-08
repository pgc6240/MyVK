//
//  PostsVC.swift
//  MyVK
//
//  Created by pgc6240 on 30.01.2021.
//

import UIKit
import Combine

final class PostsVC: UITableViewController {
    
    var owner: CanPost = User.current
    lazy var posts = owner.posts
    
    // MARK: - Subviews -
    @IBOutlet var profileHeaderView: ProfileHeaderView!
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        getPosts()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(Notification(name: Notification.Name("PostsVC.viewDidDisappear")))
    }
    
    
    // MARK: - Basic setup -
    private func configureViewController() {
        tableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.reuseId)
        PersistenceManager.pair(posts, with: tableView) { [weak self] in
            self?.profileHeaderView.set(with: self?.owner)
        }
    }
    
    
    // MARK: - Internal methods -
    @IBAction private func postsButtonTapped() {
        guard !posts.isEmpty else { return }
        tableView.scrollToRow(at: [0,0], at: .top, animated: true)
    }
    
    
    // MARK: - External methods -
    func set(with owner: CanPost) {
        self.owner = owner
        self.posts = owner.posts
    }
    
    
    func getPosts() {
        let ownerId = owner is User ? owner.id : -owner.id
        NetworkManager.shared.getPosts(ownerId: ownerId) { [weak self] posts in
            PersistenceManager.save(posts, in: self?.owner.posts)
        }
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
            friendsVC?.avaliableLetters      = avaliableLetters
            friendsVC?.numberOfRowsInSection = numberOfRowsInSection
        case .toGroups: (segue.destination as? GroupsVC)?.user = owner as? User
        case .toPhotos: (segue.destination as? PhotosVC)?.owner = owner
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard (sender as? UIButton)?.currentTitle != "0" else { return false }
        return identifier == SegueIdentifier.toPhotos.rawValue || owner is User
    }
    
    
    // MARK: - Prepare for segue to FriendsVC -
    private var avaliableLetters = [String]()
    
    
    private func updateAvaliableLetters(with friends: [User]?) {
        guard let friends = friends else { return }
        var avaliableLetters: Set<String> = []
        for friend in friends {
            guard let letter = friend.lastNameFirstLetter else { continue }
            avaliableLetters.insert(letter)
        }
        self.avaliableLetters = avaliableLetters.sorted(by: <)
        print("finished 1")
        calculateNumberOfRowsInSectionForFriendsVC(friends)
    }
    
    
    private var numberOfRowsInSection: [Int: Int] = [:]
    
    
    private func calculateNumberOfRowsInSectionForFriendsVC(_ friends: [User]) {
        for (i, letter) in avaliableLetters.enumerated() {
            let numberOfRows = friends.filter { $0.lastNameFirstLetter == letter }.count
            numberOfRowsInSection[i] = numberOfRows
        }
        print("finished 2")
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension PostsVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if posts.isEmpty {
            return "Нет записей".localized
        } else if owner as? User == User.current {
            return "Мои записи".localized
        } else if let user = owner as? User {
            return "Записи".localized + " \(user.nameGen)"
        } else {
            return "Записи".localized + " \(owner.name)"
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        posts.isEmpty ? nil : String(posts.count) + " записей".localized
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.set(with: post, and: owner)
        cell.delegate = parent as? ProfileVC
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
