//
//  FriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

class FriendsVC: UITableViewController {
    
    var friends: [String: [User]] = [:]
    var newFriends: [User] = []
    
    var alphabetControl = AlphabetControl(frame: .zero)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFriends()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarItem.badgeValue = "\(newFriends.count)"
    }
    
    
    func getFriends() {
        for _ in 0..<Int.random(in: 0..<100) {
            let randomFirstName = firstNames.randomElement() ?? "Иван"
            let randomLastName = lastNames.randomElement() ?? "Иванов"
            let friend = User(firstName: randomFirstName, lastName: randomLastName)
            
            let firstLetter = String(friend.lastName.first!)
            friends[firstLetter] == nil ? friends[firstLetter] = [friend] : friends[firstLetter]?.append(friend)
        }
        for _ in 0..<Int.random(in: 1...3) {
            let randomFirstName = firstNames.randomElement() ?? "Иван"
            let randomLastName = lastNames.randomElement() ?? "Иванов"
            let newFriend = User(firstName: randomFirstName, lastName: randomLastName)
            
            newFriends.append(newFriend)
        }
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension FriendsVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Заявки в друзья" : friends.keys.sorted(by: <)[section - 1]
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1 + friends.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return newFriends.count
        } else {
            let sectionHeader = friends.keys.sorted(by: <)[section - 1]
            return friends[sectionHeader]!.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseId) as! FriendCell
        var friend: User
        if indexPath.section == 0 {
            friend = newFriends[indexPath.row]
        } else {
            let section = friends.keys.sorted(by: <)[indexPath.section - 1]
            friend = friends[section]![indexPath.row]
        }
        cell.set(with: friend)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}


extension FriendsVC: AlphabetControlDelegate {

    @IBAction func sortButtonTapped() {
        alphabetControl.removeFromSuperview()
        let letters = friends.keys.sorted(by: <).joined()
        let rows = (CGFloat(letters.count) / 6).rounded(.up)
        let frame = CGRect(x: view.bounds.midX - 132, y: view.bounds.midY - 110, width: 264, height: rows * 44)
        alphabetControl = AlphabetControl(letters: letters, frame: frame)
        alphabetControl.delegate = self
        guard !view.subviews.contains(alphabetControl) else { return }
        view.addSubview(alphabetControl)
    }
    
    
    func letterTapped(_ letter: String) {
        let sectionsHeaders = friends.keys.sorted(by: <)
        guard let sectionIndex = sectionsHeaders.firstIndex(of: letter) else { return }
        let indexPath = IndexPath(row: 0, section: sectionIndex + 1)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        alphabetControl.delegate = nil
        alphabetControl.removeFromSuperview()
    }
}
