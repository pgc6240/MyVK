//
//  SearchVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

final class SearchVC: UITableViewController {

    var searchQuery: String?
    var searchResults: [Group] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setEditing(true, animated: false)
        configureSearchController()
    }
    
    
    func searchGroups(with searchQuery: String?) {
        guard let searchQuery = searchQuery, !searchQuery.isEmpty else { return }
        
        showLoadingView()
        NetworkManager.shared.searchGroups(searchQuery) { [weak self] searchResults in
            self?.dismissLoadingView()
            self?.searchResults = searchResults
            self?.tableView.reloadSections([0], with: .automatic)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
           let profileVC = segue.destination as? PostsVC,
           let group = PersistenceManager.create(searchResults[indexPath.row]) {
            
            profileVC.owner = group
        }
    }
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource
//
extension SearchVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Результаты поиска".localized
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.reuseId) as! GroupCell
        let group = searchResults[indexPath.row]
        cell.set(with: group)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isLoading
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let group = searchResults[indexPath.row]
        if group.isMember {
            return .delete
        } else if group.isOpen {
            return .insert
        }
        return .none
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let group = searchResults[indexPath.row]
        let groupsVC = navigationController?.viewControllers.first { $0 is GroupsVC } as? GroupsVC
        
        if editingStyle == .insert {
            groupsVC?.joinGroup(group, onSuccess: { [weak self] in
                self?.searchGroups(with: self?.searchQuery)
            })
        } else if editingStyle == .delete {
            groupsVC?.leaveGroup(group, onSuccess: { [weak self] in
                self?.searchGroups(with: self?.searchQuery)
            })
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "Выйти из сообщества".localized
    }
}


//
// MARK: - UISearchBarDelegate
//
extension SearchVC: UISearchBarDelegate {
    
    private func configureSearchController() {
        let searchController                                  = UISearchController()
        searchController.searchBar.delegate                   = self
        searchController.searchBar.placeholder                = "Поиск сообществ".localized
        searchController.searchBar.autocorrectionType         = .no
        searchController.searchBar.autocapitalizationType     = .sentences
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchQuery = searchBar.text
        searchGroups(with: searchQuery)
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
        tableView.reloadData()
    }
}
