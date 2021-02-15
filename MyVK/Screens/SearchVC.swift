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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
           let profileVC = segue.destination as? ProfileVC {
            if let user = searchResults[indexPath.row] as? User {
                profileVC.owner = PersistenceManager.create(user)
            } else if let group = searchResults[indexPath.row] as? Group {
                profileVC.owner = PersistenceManager.create(group)
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CanPostCell.reuseId) as! CanPostCell
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
}


//
// MARK: - UISearchBarDelegate
//
extension SearchVC: UISearchBarDelegate {
    
    private func configureSearchController() {
        let searchController                                  = UISearchController()
        searchController.searchBar.delegate                   = self
        searchController.searchBar.autocorrectionType         = .no
        searchController.searchBar.autocapitalizationType     = .sentences
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false
        
        switch searchFor {
        case .user:    searchController.searchBar.placeholder = "Найти пользователя".localized
        case .group:   searchController.searchBar.placeholder = "Найти сообщество".localized
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
