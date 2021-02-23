//
//  PostsVC.swift
//  MyVK
//
//  Created by pgc6240 on 30.01.2021.
//

import UIKit
import Combine
import RealmSwift

final class PostsVC: UITableViewController {
    
    var owner: CanPost = User.current
    lazy var posts     = owner.posts
    
    private var getPostsTask: AnyCancellable?
    private var _isLoading = true
    
    // MARK: - Subviews
    private lazy var profileHeaderView = tableView.tableHeaderView as? ProfileHeaderView
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.reuseId)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPosts()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        getPostsTask?.cancel()
        super.viewWillDisappear(animated)
        guard !(navigationController?.visibleViewController is NewsVC) else { return }
        NotificationCenter.default.post(Notifications.postsVCviewWillDisappear.notification)
    }
    
    
    // MARK: - External methods -
    func set(with owner: CanPost, and profileHeaderView: ProfileHeaderView) {
        self.owner = owner
        self.posts = owner.posts
        tableView.tableHeaderView = profileHeaderView
        if owner.postsCount > -1 {
            profileHeaderView.set(with: owner)
        }
        getPosts()
    }
    
    
    func getPosts() {
        let ownerId = owner is User ? owner.id : -owner.id
        getPostsTask = NetworkManager.shared.getPosts(ownerId: ownerId) { [weak self] posts, postsCount in
            PersistenceManager.write { self?.owner.postsCount = postsCount ?? 0 }
            PersistenceManager.save(posts, in: self?.owner.posts) {
                self?.updateUI()
            }
        }
    }
    
    
    func cleanUp() {
        posts = List<Post>()
        tableView.reloadData()
    }
    
    
    // MARK: - Internal methods -
    private func updateUI() {
        _isLoading = false
        profileHeaderView?.set(with: owner)
        tableView.reloadSections([0], with: .automatic)
    }
    
    
    private func reloadPosts() {
        if posts.isEmpty && !_isLoading {
            posts = owner.posts
            tableView.reloadSections([0], with: .fade)
        } else {
            guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
            tableView.reloadRows(at: indexPaths, with: .fade)
        }
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension PostsVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if _isLoading && posts.isEmpty {
            return "Загрузка...".localized
        } else if posts.isEmpty {
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
        cell.delegate = parent as? PostCellDelegate
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
