//
//  FriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit
import RealmSwift

final class FriendsVC: UITableViewController {
    
    var user: User! = User.current
    lazy var friends = user.friends
    
    var availableLetters = [String]()
    private var alphabetPicker = AlphabetPicker()
    
    var numberOfRowsInSection = [Int: Int]()
    private lazy var profileVC = prevVC as? ProfileVC
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewController()
        if let profileVC = profileVC, !profileVC.numberOfRowsInSection.isEmpty, numberOfRowsInSection.isEmpty {
            showLoadingView()
        } else {
            getFriends()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let profileVC = profileVC, !profileVC.numberOfRowsInSection.isEmpty, numberOfRowsInSection.isEmpty {
            loadPreparedData()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissLoadingView()
        super.viewWillDisappear(animated)
        guard navigationController?.visibleViewController is PostsVC else { return }
        NotificationCenter.default.post(Notification(name: Notification.Name("FriendsVC.viewDidDisappear")))
    }
    
    
    // MARK: - Basic setup -
    private func configureTableView() {
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "headerReuseId")
        tableView.rowHeight = 76
    }
    
    
    private func configureViewController() {
        navigationItem.title = user == User.current ? "Мои друзья".localized : user.name
        navigationItem.searchController?.searchBar.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.transition(with: self.view, duration: 0.6, options: []) {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }
    
    
    private func loadPreparedData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let profileVC = self.profileVC else { return }
            self.availableLetters      = profileVC.availableLetters
            self.numberOfRowsInSection = profileVC.numberOfRowsInSection
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.dismissLoadingView()
            }
        }
    }
    
    
    // MARK: - External methods -
    func getFriends() {
        if tableView.visibleCells.count < 1 {
            showLoadingView()
        }
        NetworkManager.shared.getFriends(userId: user.id) { [weak self] friends in
            PersistenceManager.save(friends, in: self?.user.friends)
            self?.updateUI()
        }
    }
    
    
    // MARK: - Internal methods -
    private func updateUI() {
        updateAvailableLetters()
        tableView.reloadData()
        dismissLoadingView()
    }
    
    
    private func updateAvailableLetters() {
        var availableLetters: Set<String> = []
        for friend in friends {
            guard let letter = friend.lastNameFirstLetter else { continue }
            availableLetters.insert(letter)
        }
        self.availableLetters = availableLetters.sorted(by: <)
    }
    
    
    // MARK: - Utility methods -
    private func friendsForLetter(_ letter: String) -> Results<User> {
        friends.filter("lastNameFirstLetter = %@", letter)
    }
    
    
    private func friendForIndexPath(_ indexPath: IndexPath) -> User {
        let letter = letterForSection(indexPath.section)
        return friendsForLetter(letter)[indexPath.row]
    }
    
    
    private func sectionForLetter(_ letter: String) -> Int? {
        availableLetters.firstIndex(of: letter)
    }
    
    
    private func letterForSection(_ section: Int) -> String {
        availableLetters[section]
    }
    

    // MARK: - Segues -
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let indexPath = tableView.indexPathForSelectedRow else { return false }
        let user = friendForIndexPath(indexPath)
        return user.canAccessClosed
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
           let profileVC = segue.destination as? ProfileVC
        {
            profileVC.owner = friendForIndexPath(indexPath)
        }
        navigationItem.searchController?.searchBar.isHidden = true
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate -
//
extension FriendsVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        availableLetters.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !numberOfRowsInSection.isEmpty {
            return numberOfRowsInSection[section] ?? 0
        }
        
        let letter = letterForSection(section)
        return friendsForLetter(letter).count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseId) as! FriendCell
        let friend = friendForIndexPath(indexPath)
        cell.set(with: friend)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        availableLetters
    }
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        sectionForLetter(title) ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerReuseId")
        sectionHeader?.backgroundView  = BlurView()
        sectionHeader?.textLabel?.text = letterForSection(section)
        return sectionHeader
    }
}


//
// MARK: - AlphabetPickerDelegate -
//
extension FriendsVC: AlphabetPickerDelegate {

    @IBAction func sortButtonTapped() {
        if view.subviews.contains(alphabetPicker) {
            alphabetPicker.removeFromSuperview()
        } else {
            let letters = availableLetters.map { String($0) }.joined()
            alphabetPicker = AlphabetPicker(with: letters, in: view)
            alphabetPicker.delegate = self
            view.addSubview(alphabetPicker)
        }
    }
    
    
    func letterTapped(_ alphabetPicker: AlphabetPicker, letter: String) {
        guard let section = sectionForLetter(letter) else { return }
        tableView.scrollToRow(at: [section, 0], at: .top, animated: true)
        alphabetPicker.removeFromSuperview()
    }
}


//
// MARK: - UIScrollViewDelegate -
//
extension FriendsVC {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        alphabetPicker.removeFromSuperview()
    }
}


//
// MARK: - UISearchBarDelegate -
//
extension FriendsVC: UISearchBarDelegate {
    
    private func configureSearchController() {
        let searchController                                  = UISearchController()
        searchController.searchBar.delegate                   = self
        searchController.searchBar.autocorrectionType         = .no
        searchController.searchBar.autocapitalizationType     = .words
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false

        if user == User.current {
            searchController.searchBar.placeholder = "Поиск среди моих друзей".localized
        } else if Locale.isEnglishLocale {
            searchController.searchBar.placeholder = "Search in user's friends"
        } else {
            searchController.searchBar.placeholder = "Поиск среди друзей \(user.nameGen)"
        }
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            friends = user.friends
        } else {
            //friends = user.friends.filter("firstName BEGINSWITH %@ || lastName BEGINSWITH %@", searchText, searchText)
        }
        updateUI()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        friends = user.friends
        updateUI()
    }
}
