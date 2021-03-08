//
//  SearchVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

final class SearchVC: UITableViewController {

    enum SearchType { case user, group }
    
    var searchFor: SearchType    = .user
    var searchResults: [CanPost] = [] { didSet { updateUI() }}
    
    
    // MARK: - View controller lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setEditing(true, animated: false)
        configureSearchController()
    }
    
    
    // MARK: - External methods -
    func search(with searchQuery: String?) {
        guard let searchQuery = searchQuery, !searchQuery.isEmpty else { return }
        showLoadingView()
        switch searchFor {
        case .user:  searchUsers(with: searchQuery)
        case .group: searchGroups(with: searchQuery)
        }
    }
    
    
    func searchUsers(with searchQuery: String) {
        NetworkManager.shared.searchUsers(searchQuery) { [weak self] users in
            self?.searchResults = users
        }
    }
    
    
    func searchGroups(with searchQuery: String) {
        NetworkManager.shared.searchGroups(searchQuery) { [weak self] groups in
            self?.searchResults = groups
        }
    }
    
    
    // MARK: - Internal methods -
    private func updateUI() {
        dismissLoadingView()
        tableView.reloadSections([0], with: .automatic)
    }
    
    
    // MARK: - Segues -
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let indexPath = tableView.indexPathForSelectedRow else { return false }
        switch searchFor {
        case .user:  return (searchResults[indexPath.row] as? User)?.canAccessClosed ?? false
        case .group: return (searchResults[indexPath.row] as? Group)?.isOpen ?? false
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow, let profileVC = segue.destination as? ProfileVC else { return }
        if let user  = searchResults[indexPath.row] as? User,
           let owner = PersistenceManager.create(user) {
            profileVC.owner = owner
        } else if let group = searchResults[indexPath.row] as? Group,
                  let owner = PersistenceManager.create(group) {
            profileVC.owner = owner
        }
    }
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource
//
extension SearchVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: CanPostCell.reuseId) as! CanPostCell
        let owner = searchResults[indexPath.row]
        cell.set(with: owner)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isLoading {
            return "Загрузка...".localized
        } else if searchResults.isEmpty {
            return "Нет результатов".localized
        } else {
            return "Результаты поиска".localized
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch searchFor {
        case .user:
            guard let user = searchResults[indexPath.row] as? User else { return false }
            return user.canSendFriendRequest || user.isFriend
        case .group:
            guard let group = searchResults[indexPath.row] as? Group else { return false }
            return group.isOpen || group.isMember
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch searchFor {
        case .user:
            guard let user = searchResults[indexPath.row] as? User else { return .none }
            if user.isFriend {
                return .delete
            } else if user.canSendFriendRequest {
                return .insert
            }
        case .group:
            guard let group = searchResults[indexPath.row] as? Group else { return .none }
            if group.isMember {
                return .delete
            } else if group.isOpen {
                return .insert
            }
        }
        return .none
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch searchFor {
        case .user:
            guard let user      = searchResults[indexPath.row] as? User,
                  let friendsVC = previousViewController as? FriendsVC else { return }
            if editingStyle == .insert {
                friendsVC.addFriend(with: user.id) { [weak self] in
                    user.isFriend = true
                    self?.updateUI()
                }
            }
        case .group:
            guard let group    = searchResults[indexPath.row] as? Group,
                  let groupsVC = previousViewController as? GroupsVC else { return }
            if editingStyle == .insert {
                groupsVC.joinGroup(group) { [weak self] in
                    group.isMember = true
                    self?.updateUI()
                }
            } else if editingStyle == .delete {
                groupsVC.leaveGroup(group) { [weak self] in
                    group.isMember = false
                    self?.updateUI()
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        switch searchFor {
        case .user:  return "Удалить из друзей".localized
        case .group: return "Выйти из сообщества".localized
        }
    }
}


//
// MARK: - UISearchBarDelegate
//
extension SearchVC: UISearchBarDelegate {
    
    private func configureSearchController() {
        let searchController                                  = UISearchController()
        searchController.searchBar.delegate                   = self
        searchController.searchBar.autocorrectionType         = .no
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false
        
        switch searchFor {
        case .user:
            searchController.searchBar.placeholder            = "Найти пользователя".localized
            searchController.searchBar.autocapitalizationType = .words
        case .group:
            searchController.searchBar.placeholder            = "Найти сообщество".localized
            searchController.searchBar.autocapitalizationType = .sentences
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(with: searchBar.text)
        updateUI()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
    }
}
