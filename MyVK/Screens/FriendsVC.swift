//
//  FriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

final class FriendsVC: UITableViewController {
    
    var friends: [[User]] = []
    
    var alphabetControl = AlphabetPicker()
    var avaliableLetters: Set<String> = []
    
    let collation = UILocalizedIndexedCollation.current()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        getFriends()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarItem.badgeValue = "\(friends[0].count)"
    }
    
    
    func getFriends() {
        friends = [[User]](repeating: [], count: collation.sectionTitles.count + 1)
        
        for _ in 0..<Int.random(in: 0..<500) {
            let friend = makeFriend()
            let sectionIndex = collation.section(for: friend, collationStringSelector: #selector(getter:User.lastName))
            friends[sectionIndex + 1].append(friend)
            avaliableLetters.insert(collation.sectionTitles[sectionIndex])
        }
        
        friends[0] = makeRandomNumberOfFriends(upTo: 3)
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension FriendsVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Заявки в друзья" : (friends[section].isEmpty ? nil : collation.sectionTitles[section - 1])
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        friends.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friends[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseId) as! FriendCell
        let friend = friends[indexPath.section][indexPath.row]
        cell.set(with: friend)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        collation.sectionTitles.filter { avaliableLetters.contains($0) }
    }
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        collation.sectionTitles.firstIndex(of: title)! + 1
    }
}


//
// MARK: - AlphabetPickerDelegate
//
extension FriendsVC: AlphabetPickerDelegate {

    @IBAction func sortButtonTapped() {
        alphabetControl.removeFromSuperview()
        alphabetControl = AlphabetPicker(with: avaliableLetters.joined(), in: view)
        alphabetControl.delegate = self
        view.addSubview(alphabetControl)
    }
    
    
    func letterTapped(_ letter: String) {
        guard let sectionIndex = collation.sectionTitles.firstIndex(of: letter) else { return }
        
        tableView.scrollToRow(at: [sectionIndex + 1, 0], at: .top, animated: true)
        alphabetControl.removeFromSuperview()
    }
}
