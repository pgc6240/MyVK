//
//  FriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

class FriendsVC: UITableViewController {
    
    var friends: [[User]] = []
    var newFriends: [User] = []
    
    let collation = UILocalizedIndexedCollation.current()
    var avaliableLetters: Set<String> = []
    var alphabetControl = AlphabetControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        getFriends()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarItem.badgeValue = "\(newFriends.count)"
    }
    
    
    func getFriends() {
        friends = [[User]](repeating: [], count: collation.sectionTitles.count)
        
        for _ in 0..<Int.random(in: 0..<500) {
            let friend = makeFriend()
            let sectionIndex = collation.section(for: friend, collationStringSelector: #selector(getter:User.lastName))
            friends[sectionIndex].append(friend)
            avaliableLetters.insert(collation.sectionTitles[sectionIndex])
        }
        
        newFriends = makeRandomNumberOfFriends(upTo: 3)
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension FriendsVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Заявки в друзья"
        } else {
            return friends[section - 1].isEmpty ? nil : collation.sectionTitles[section - 1]
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1 + friends.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? newFriends.count : friends[section - 1].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseId) as! FriendCell
        let friend = indexPath.section == 0 ? newFriends[indexPath.row] : friends[indexPath.section - 1][indexPath.row]
        cell.set(with: friend)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension FriendsVC: AlphabetControlDelegate {

    @IBAction func sortButtonTapped() {
        alphabetControl.removeFromSuperview()
        alphabetControl = AlphabetControl(with: avaliableLetters.joined(), in: view)
        alphabetControl.delegate = self
        view.addSubview(alphabetControl)
    }
    
    
    func letterTapped(_ letter: String) {
        guard let sectionIndex = collation.sectionTitles.firstIndex(of: letter) else { return }
        
        tableView.scrollToRow(at: [sectionIndex + 1, 0], at: .top, animated: true)
        alphabetControl.removeFromSuperview()
    }
}
