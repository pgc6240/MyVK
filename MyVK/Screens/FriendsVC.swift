//
//  FriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

final class FriendsVC: UITableViewController {
    
    var friends: [[User]] = []
    lazy var backingStore: [[User]] = []
    
    var alphabetControl = AlphabetPicker()
    var avaliableLetters: Set<String> = []
    
    let collation = UILocalizedIndexedCollation.current()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchController()
        getFriends()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarItem.badgeValue = "\(friends[0].count)"
    }
    
    
    private func configureTableView() {
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.rowHeight = 80
    }
    
    
    func getFriends() {
        friends = [[User]](repeating: [], count: collation.sectionTitles.count + 1)
        
        for _ in 0..<Int.random(in: 0..<500) {
            let friend = makeFriend()
            let sectionIndex = collation.section(for: friend, collationStringSelector: #selector(getter:User.lastName))
            friends[sectionIndex + 1].append(friend)
        }
        
        friends[0] = makeRandomNumberOfFriends(upTo: 3)
        
        backingStore = friends
        
        updateAvaliableLetters()
    }
    
    
    private func updateAvaliableLetters() {
        avaliableLetters = []
        friends.forEach { $0.forEach { avaliableLetters.insert(String($0.lastName.first ?? "A")) }}
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate
//
extension FriendsVC {
    
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
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        friends[section].isEmpty ? 0 : UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !friends[section].isEmpty {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
            header?.backgroundView = BlurView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
            header?.textLabel?.text = section == 0 ? "Заявки в друзья" : collation.sectionTitles[section - 1]
            return header
        }
        return nil
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


//
// MARK: - UISearchBarDelegate
//
extension FriendsVC: UISearchBarDelegate {
    
    private func configureSearchController() {
        let searchController                                    = UISearchController()
        searchController.searchBar.delegate                     = self
        searchController.searchBar.placeholder                  = "Поиск среди моих друзей"
        searchController.searchBar.autocapitalizationType       = .words
        searchController.obscuresBackgroundDuringPresentation   = false
        navigationItem.searchController                         = searchController
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            friends = backingStore

        } else {
            friends = backingStore.map { $0.filter { friend in
                
                let firstName           = friend.firstName.lowercased()
                let lastName            = friend.lastName.lowercased()
                let wordsInSearchQuery  = searchText.lowercased().split(separator: " ")
                
                for word in wordsInSearchQuery {
                    return firstName.contains(word) || lastName.contains(word)
                }
                return false
            }}
        }
        
        updateAvaliableLetters()
        
        tableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        friends = backingStore
        updateAvaliableLetters()
        tableView.reloadData()
    }
}
