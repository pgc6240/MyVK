//
//  FriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit
import RealmSwift

final class FriendsVC: UITableViewController {
    
    var user: User!  = User.current
    lazy var friends = user.friends
    
    var availableLetters       = [String]()
    private var alphabetPicker = AlphabetPicker()
    
    var numberOfRowsInSection  = [Int: Int]()
    private lazy var profileVC = prevVC as? ProfileVC
    
    private var isFiltering    = false
    private var filteredFriends: Results<User>!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewController()
        if let profileVC = profileVC, !profileVC.numberOfRowsInSection.isEmpty, numberOfRowsInSection.isEmpty, !friends.isEmpty {
            showLoadingView()
        } else {
            if tableView.visibleCells.isEmpty {
                getFriends()
            } else {
                guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
                tableView.reloadRows(at: indexPaths, with: .none)
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let profileVC = profileVC, !profileVC.numberOfRowsInSection.isEmpty, numberOfRowsInSection.isEmpty, !friends.isEmpty {
            loadPreparedData()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissLoadingView()
        super.viewWillDisappear(animated)
        guard navigationController?.visibleViewController is ProfileVC else { return }
        NotificationCenter.default.post(Notifications.friendsVCviewWillDisappear.notification)
    }
    
    
    // MARK: - Basic setup -
    private func configureTableView() {
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "headerReuseId")
        tableView.rowHeight = 76
    }
    
    
    private func configureViewController() {
        navigationItem.title = user == User.current ? "Мои друзья".localized : user.name
        navigationItem.leftBarButtonItem = user == User.current ? searchButton : nil
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
        showLoadingView()
        NetworkManager.shared.getFriends(userId: user.id) { [weak self] friends in
            PersistenceManager.save(friends, in: self?.user.friends) {
                self?.updateUI()
            }
        }
    }
    
    
    func addFriend(with userId: Int, onSuccess: @escaping () -> Void = {}) {
        showLoadingView()
        NetworkManager.shared.addFriend(with: userId) { [weak self] isSuccessful in
            self?.dismissLoadingView()
            if isSuccessful {
                self?.presentAlert(title: "Заявка на добавление в друзья отправлена.".localized)
                onSuccess()
            } else {
                self?.presentFailureAlert()
            }
        }
    }
    
    
    // MARK: - Internal methods -
    private func updateUI() {
        if !isFiltering {
            updateAvailableLetters()
        }
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
        if isFiltering {
            return filteredFriends[indexPath.row]
        }
        
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
    private enum SegueIdentifier: String {
        case toProfile
        case toSearch
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let segueIdentifier = SegueIdentifier(rawValue: identifier) else { return false }
        switch segueIdentifier {
        case .toSearch:  return true
        case .toProfile:
            guard let indexPath = tableView.indexPathForSelectedRow else { return false }
            let user = friendForIndexPath(indexPath)
            return user.canAccessClosed
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.searchController?.searchBar.isHidden = true
        
        guard let segueIdentifier = SegueIdentifier(rawValue: segue.identifier ?? "") else { return }
        switch segueIdentifier {
        case .toProfile:
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let profileVC = segue.destination as? ProfileVC else { return }
                profileVC.owner = friendForIndexPath(indexPath)
        case .toSearch:
            guard let searchVC = segue.destination as? SearchVC else { return }
            searchVC.searchFor = .user
        }
    }
}


//
// MARK: - UITableViewDataSource & UITableViewDelegate -
//
extension FriendsVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        isFiltering ? 1 : availableLetters.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredFriends.count
        }
        
        if numberOfRowsInSection.count == availableLetters.count {
            return numberOfRowsInSection[section] ?? 0
        }
        
        let letter = letterForSection(section)
        let numberOfRows = friendsForLetter(letter).count
        numberOfRowsInSection[section] = numberOfRows
        return numberOfRows
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
        isFiltering ? nil : availableLetters
    }
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        sectionForLetter(title) ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isFiltering {
            return nil
        }
        
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerReuseId")
        sectionHeader?.backgroundView  = BlurView()
        sectionHeader?.textLabel?.text = letterForSection(section)
        return sectionHeader
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        isFiltering ? 0 : UITableView.automaticDimension
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
            isFiltering = false
        } else {
            filteredFriends = user.friends.filter("firstName BEGINSWITH %@ || lastName BEGINSWITH %@", searchText, searchText)
            isFiltering = true
        }
        updateUI()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        updateUI()
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
            alphabetPicker = AlphabetPicker(with: availableLetters.joined(), in: view)
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
