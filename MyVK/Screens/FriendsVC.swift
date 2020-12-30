//
//  FriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit
import RealmSwift

final class FriendsVC: UITableViewController {
    
    var friends: [[User]] = []
    private lazy var backingStore: [[User]] = []
    
    private var alphabetPicker = AlphabetPicker()
    private var avaliableLetters: Set<String> = []
    
    private let collation = UILocalizedIndexedCollation.current()
    
    private let headerReuseId = "letterHeader"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchController()
        getFriends()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.searchController?.searchBar.isHidden = false /* animation-related */
    }
    
    
    private func configureTableView() {
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerReuseId)
        tableView.rowHeight = 76
    }
    
    
    private func configureSearchController() {
        let searchController                                  = UISearchController()
        searchController.searchBar.delegate                   = self
        searchController.searchBar.placeholder                = "Поиск среди моих друзей".localized
        searchController.searchBar.autocorrectionType         = .no
        searchController.searchBar.autocapitalizationType     = .words
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false
    }
    
    
    func getFriends() {
        friends = [[User]](repeating: [], count: collation.sectionTitles.count)
        
        if let storedFriends = PersistenceManager.load(User.self) {
            updateFriends(with: storedFriends)
        }
        
        NetworkManager.shared.getFriends { [weak self] friends in
            self?.updateFriends(with: friends)
            PersistenceManager.save(friends)
        }
    }
    
    
    private func updateFriends(with friends: [User]) {
        var friendsUpdated = false
        
        friends.forEach { friend in
            if Locale.current.languageCode == "en" {
                localize(friend)
            }
            
            let sectionIndex = self.collation.section(for: friend,
                                                      collationStringSelector: #selector(getter:User.lastName))
            if self.friends[sectionIndex].updating(with: friend) {
                friendsUpdated = true
            }
        }
        
        if friendsUpdated {
            backingStore = self.friends
            updateUI()
        }
    }
    
    
    private func localize(_ friend: User) {
        do {
            let realm = try Realm()
            try realm.write {
                friend.firstName = friend.firstName.toLatin
                friend.lastName = friend.lastName.toLatin
            }
        } catch {
            print(error)
        }
    }
    
    
    private func updateUI() {
        updateAvaliableLetters()
        tableView.reloadData()
    }
    
    
    private func updateAvaliableLetters() {
        avaliableLetters = []
        friends.forEach { $0.forEach { avaliableLetters.insert(String($0.lastName.first ?? " ")) }}
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let photosVC = segue.destination as? PhotosVC {
            
            let friend = friends[indexPath.section][indexPath.row]
            photosVC.userId = friend.id
        }
        
        navigationItem.searchController?.searchBar.isHidden = true /* animation-related */
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
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        friends[section].isEmpty ? 0 : UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !friends[section].isEmpty else { return nil }
        
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseId)
        sectionHeader?.backgroundView = BlurView()
        sectionHeader?.textLabel?.text = collation.sectionTitles[section]
        return sectionHeader
    }
}


//
// MARK: - AlphabetPickerDelegate
//
extension FriendsVC: AlphabetPickerDelegate {

    @IBAction func sortButtonTapped() {
        if view.subviews.contains(alphabetPicker) {
            alphabetPicker.removeFromSuperview()
        } else {
            let letters = avaliableLetters.filter { $0 != " " }.joined()
            alphabetPicker = AlphabetPicker(with: letters, in: view)
            alphabetPicker.delegate = self
            view.addSubview(alphabetPicker)
        }
    }
    
    
    func letterTapped(_ alphabetPicker: AlphabetPicker, letter: String) {
        guard let sectionIndex = collation.sectionTitles.firstIndex(of: letter) else { return }
        
        tableView.scrollToRow(at: [sectionIndex, 0], at: .top, animated: true)
        alphabetPicker.removeFromSuperview()
    }
}


//
// MARK: - UISearchBarDelegate
//
extension FriendsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            friends = backingStore
        } else {
            friends = backingStore.lazy.map { $0.filter { friend in
                var match = false
                let wordsInSearchQuery = searchText.split(separator: " ")
                for word in wordsInSearchQuery {
                    guard !match else { break }
                    match = friend.firstName.lowercased().contains(word.lowercased())
                            ||
                            friend.lastName.lowercased().contains(word.lowercased())
                }
                return match
            }}
        }
        updateUI()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        friends = backingStore
        updateUI()
    }
}


//
// MARK: - UIScrollViewDelegate
//
extension FriendsVC {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        alphabetPicker.removeFromSuperview()
    }
}
