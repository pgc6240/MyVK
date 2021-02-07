//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 07.02.2021.
//

import UIKit
import RealmSwift

final class NewsVC: UITableViewController {
    
    var posts = User.current?.newsfeed
    private var token: NotificationToken?
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        PersistenceManager.pair(posts, with: tableView, token: &token)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNewsfeed()
    }
    
    
    // MARK: - External methods -
    func getNewsfeed() {
        if posts?.count == 0 {
            parent?.showLoadingView()
        }
        NetworkManager.shared.getNewsfeed { [weak self] posts in
            self?.parent?.dismissLoadingView()
            PersistenceManager.save(posts, in: User.current.newsfeed)
        }
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate -
//
extension NewsVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        if let post = posts?[indexPath.row] {
            cell.set(with: post)
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
