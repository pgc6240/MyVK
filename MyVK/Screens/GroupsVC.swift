//
//  GroupsVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

class GroupsVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource
//
extension GroupsVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        return cell
    }
}
