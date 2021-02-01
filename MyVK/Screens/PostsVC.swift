//
//  PostsVC.swift
//  MyVK
//
//  Created by pgc6240 on 30.01.2021.
//

import UIKit
import RealmSwift

final class PostsVC: UITableViewController {
    
    var owner: CanPost = User.current
    lazy var posts = owner.posts
    private var token: NotificationToken?
    private var timer: Timer?
    
    @IBOutlet var profileHeaderView: ProfileHeaderView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        configureTableViewController()
        updateUI()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        token?.invalidate()
        timer?.invalidate()
        timer = nil
    }
    
    
    private func configureTableViewController() {
        PersistenceManager.pair(posts, with: tableView, token: &token)
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in self?.getPosts() }
        set(with: owner)
    }
    
    
    private func updateUI() {
        profileHeaderView.set(with: owner)
    }
    
    
    // MARK: - External methods
    func set(with owner: CanPost) {
        self.owner = owner
        self.posts = owner.posts
        getPosts()
    }
    
    
    func getPosts() {
        if owner.posts.isEmpty {
            parent?.showLoadingView()
        }
        if let user = owner as? User {
            NetworkManager.shared.getFriendsGroupsPhotosAndPosts(for: user.id) { [weak self] (friends, groups, photos, posts) in
                self?.parent?.dismissLoadingView()
                if let user = self?.owner as? User {
                    PersistenceManager.save(friends, in: user.friends)
                    PersistenceManager.save(groups, in: user.groups)
                    PersistenceManager.save(photos, in: user.photos)
                    PersistenceManager.save(posts, in: user.posts)
                }
                self?.updateUI()
            }
        } else if let group = owner as? Group {
            NetworkManager.shared.getPosts(ownerId: -group.id) { [weak self] posts in
                self?.parent?.dismissLoadingView()
                PersistenceManager.save(posts, in: group.posts)
            }
            NetworkManager.shared.getMembersPhotosAndPostsCount(for: group.id) {
                [weak self] (memberCount, photosCount, postsCount) in
                self?.profileHeaderView.set(memberCount, photosCount, postsCount)
            }
        }
    }
    
    
    func deletePost(with postId: Int) {
        let alertTitle   = "Вы точно хотите удалить запись?".localized
        let alertMessage = "Это действие будет невозможно отменить.".localized
        let alertSheet   = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        let cancel       = UIAlertAction(title: "Нет".localized, style: .default)
        let deletePost   = UIAlertAction(title: "Да".localized, style: .destructive) { [postId] _ in
            NetworkManager.shared.deletePost(postId: postId) { [weak self] isSuccessful in
                guard isSuccessful else { return }
                self?.getPosts()
            }
        }
        alertSheet.addAction(cancel)
        alertSheet.addAction(deletePost)
        alertSheet.view.tintColor = UIColor.vkColor
        present(alertSheet, animated: true)
    }
    

    // MARK: - Segues
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
        case .toPhotos: (segue.destination as? PhotosVC)?.user = owner as? User
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        owner is User
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
        cell.parent = self
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
