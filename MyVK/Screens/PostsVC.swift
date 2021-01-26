//
//  PostsVC.swift
//  MyVK
//
//  Created by pgc6240 on 22.01.2021.
//

import UIKit
import RealmSwift

final class PostsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var postsPicker: UISegmentedControl = {
        let postsPicker = UISegmentedControl(items: ["Мои записи", "Записи друзей"])
        postsPicker.selectedSegmentIndex = 0
        return postsPicker
    }()
    
    var posts = User.current.posts
    var owner: CanPost = User.current
    private var token: NotificationToken?
    private var timer: Timer?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PersistenceManager.pair(posts, with: tableView, token: &token)
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in self?.getPosts() }
        timer?.fire()
        tableView.tableHeaderView = postsPicker
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        token?.invalidate()
        timer?.invalidate()
        timer = nil
    }
    
    
    func set(with owner: CanPost) {
        self.posts = owner.posts
        self.owner = owner
        getPosts()
    }
    
    
    func getPosts() {
        let ownerId = owner is User ? owner.id : -owner.id
        NetworkManager.shared.getPosts(ownerId: ownerId) { [weak self] posts in
            guard let self = self else { return }
            PersistenceManager.save(posts, in: self.posts)
        }
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension PostsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        posts.isEmpty ? "Нет записей".localized : nil
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.set(with: post, ownerPhotoUrl: owner.photoUrl, and: owner.name)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
