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
        
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension NewsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}
