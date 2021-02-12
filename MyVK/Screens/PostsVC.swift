//
//  PostsVC.swift
//  MyVK
//
//  Created by pgc6240 on 30.01.2021.
//

import UIKit

final class PostsVC: UITableViewController {
    
    var owner: CanPost = User.current
    lazy var posts     = owner.posts
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.reuseId)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(Notification(name: Notification.Name("PostsVC.viewDidDisappear")))
    }
    
    
    // MARK: - External methods -
    func set(with owner: CanPost, and profileHeaderView: ProfileHeaderView) {
        self.owner = owner
        self.posts = owner.posts
        tableView.tableHeaderView = profileHeaderView
        PersistenceManager.pair(posts, with: tableView)
        getPosts()
    }
    
    
    func getPosts() {
        let ownerId = owner is User ? owner.id : -owner.id
        NetworkManager.shared.getPosts(ownerId: ownerId) { [weak self] posts in
            PersistenceManager.save(posts, in: self?.owner.posts)
            (self?.tableView.tableHeaderView as? ProfileHeaderView)?.set(with: self?.owner)
        }
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
        cell.delegate = parent as? MyProfileVC
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
