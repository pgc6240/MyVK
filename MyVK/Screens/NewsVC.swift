//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 07.02.2021.
//

import UIKit

final class NewsVC: UITableViewController {
    
    let posts = User.current.newsfeed
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableViewController()
        getNewsfeed()
    }
    
    
    // MARK: - Basic setup -
    private func configureTableViewController() {
        tableView.register(PostCell.nib, forCellReuseIdentifier: PostCell.reuseId)
        PersistenceManager.pair(posts, with: tableView)
    }
    
    
    // MARK: - External methods -
    func getNewsfeed() {
        if posts.isEmpty {
            showLoadingView()
        }
        NetworkManager.shared.getNewsfeed { [weak self] posts in
            self?.dismissLoadingView()
            PersistenceManager.save(posts, in: User.current.newsfeed)
        }
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate -
//
extension NewsVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.set(with: post)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
