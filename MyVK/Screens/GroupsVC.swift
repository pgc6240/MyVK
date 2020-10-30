//
//  GroupsVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

class GroupsVC: UITableViewController {
    
    var user: User?
    var groups: [Group] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGroups(for: user)
    }
    
    func loadGroups(for user: User?) {
        for i in 0..<Int.random(in: 1...100) {
            groups.append(Group(name: "Сообщество \(i)"))
        }
    }
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource
//
extension GroupsVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.reuseId) as! GroupCell
        let group = groups[indexPath.row]
        cell.set(with: group)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
