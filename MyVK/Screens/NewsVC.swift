//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit
import RealmSwift

final class NewsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: List<Post> = User.current.posts
    private var token: NotificationToken?
    private var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewContoller()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPosts()
    }
    
    
    private func configureViewContoller() {
        PersistenceManager.pair(posts, with: tableView, token: &token)
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in self?.getPosts() }
    }
    
    
    func getPosts() {
        NetworkManager.shared.getPosts { posts in
            PersistenceManager.save(posts, in: User.current.posts)
        }
    }
    
    
    @IBAction func logoutButtonTapped() {
        SessionManager.logout()
    }
    
    
    deinit {
        token?.invalidate()
        timer?.invalidate()
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension NewsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        posts.isEmpty ? "Нет записей".localized : nil
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.set(with: post)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
