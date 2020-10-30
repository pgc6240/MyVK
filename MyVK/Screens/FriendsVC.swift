//
//  FriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

class FriendsVC: UIViewController {
    
    var friends: [User] = []
    var newFriends: [User] = []
    
    let sectionHeaders = ["Заявки в друзья", "Мои друзья"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarItem.badgeValue = "\(newFriends.count)"
    }
    
    func getFriends() {
        for _ in 0..<Int.random(in: 0..<10_000) {
            friends.append(User(firstName: "Имя", lastName: "Фамилия"))
        }
        for _ in 0..<Int.random(in: 1...3) {
            newFriends.append(User(firstName: "Имя", lastName: "Фамилия"))
        }
    }
}

//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension FriendsVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionHeaders[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return newFriends.count
        } else {
            return friends.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseId) as! FriendCell
        let friend = friends[indexPath.row]
        cell.set(with: friend)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let friend = friends[indexPath.row]
        let photosVC = PhotosVC()
        photosVC.friend = friend
        navigationController?.pushViewController(photosVC, animated: true)
    }
}
