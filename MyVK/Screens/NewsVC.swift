//
//  NewsVC.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class NewsVC: UIViewController {

    var posts: [Post] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
    }
    
    
    func getPosts() {
        NetworkManager.shared.getPosts { posts in
            print(posts.count)
        }
    }
    
    
    @IBAction func logoutButtonTapped() {
        SessionManager.logout()
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension NewsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseId, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.set(with: post)
        return cell
    }
}
