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
    var posts          = List<Post>()
    
    var textCroppedAtIndexPath = [IndexPath: Bool]()
    
    private var getPostsTask: AnyCancellable?
    private var _isLoading = true
    
    private lazy var profileHeaderView = (parent as? ProfileVC)?.profileHeaderView
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.reuseId)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableHeaderView = profileHeaderView
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.posts = self.owner.posts
            self.getPosts()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        getPostsTask?.cancel()
        super.viewWillDisappear(animated)
        guard !(navigationController?.visibleViewController is NewsVC) else { return }
        NotificationCenter.default.post(Notifications.postsVCviewWillDisappear.notification)
    }
    
    
    // MARK: - External methods -
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
    
    
    func showMoreTextAtIndexPath(_ indexPath: IndexPath) {
        textCroppedAtIndexPath[indexPath]?.toggle()
        UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve) { [weak tableView] in
            tableView?.reloadData()
        }
    }
    
    
    // MARK: - Internal methods -
    private func updateUI() {
        _isLoading = false
        profileHeaderView?.set(with: owner)
        tableView.reloadSections([0], with: .automatic)
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
        cell.set(with: post, textCropped: &textCroppedAtIndexPath[indexPath])
        cell.delegate = parent as? PostCellDelegate
        cell.tag = indexPath.row
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if let photo = post.photos.first, let postText = post.text {
            let cellWidth   = tableView.bounds.width
            let photoHeight = cellWidth * photo.aspectRatio
            let textHeight  = (textCroppedAtIndexPath[indexPath] ?? true) ? 200 : postText.size(in: cellWidth).height
            return 60 + textHeight + photoHeight + 35
        }
        return UITableView.automaticDimension
    }
}
