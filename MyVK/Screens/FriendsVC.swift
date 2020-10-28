//
//  FriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

class FriendsVC: UITableViewController {

    var friends: [Friend] = []
    var newFriends = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarItem.badgeValue = "\(newFriends)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let cellIndex = tableView.indexPath(for: cell)?.row {
                let friend = friends[cellIndex]
                let photosVC = segue.destination as! PhotosVC
                photosVC.friend = friend
            }
        }
    }
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource
//
extension FriendsVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //#warning("Сделать 2 секции: 'Заявки в друзья' и 'Мои друзья'")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        let friend = friends[indexPath.row]
        cell.textLabel?.text = "\(friend.id) \(friend.firstName)"
        cell.detailTextLabel?.text = friend.lastName
        return cell
    }
}


//
// MARK: - Dummy data
//
extension FriendsVC {
    
    func loadFriends() {
        let randomFriendCount = Int.random(in: 0..<10_000)
        for i in 0..<randomFriendCount {
            let friend = Friend(id: i, firstName: "Имя", lastName: "Фамилия")
            friends.append(friend)
        }
        newFriends = Int.random(in: 1...3)
    }
}
