//
//  SearchVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

final class SearchVC: UITableViewController {

    var searchResults: [Group] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setEditing(true, animated: false)
        configureSearchController()
    }
    
    
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
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource
//
extension SearchVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.reuseId) as! GroupCell
        let group = searchResults[indexPath.row]
        cell.set(with: group)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Результаты поиска".localized
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let group = searchResults[indexPath.row]
        return group.isOpen
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let group = searchResults[indexPath.row]
        
        showLoadingView()
        if editingStyle == .insert {
            NetworkManager.shared.joinGroup(groupId: group.id) { [weak self] isSuccessful in
                self?.dismissLoadingView()
                
                if isSuccessful {
                    self?.presentAlert(title: "Hooray! 🎉", message: "\nВы теперь состоите в сообществе\n\"\(group.name)\".")
                    group.isMember = true
                } else {
                    self?.presentAlert(title: "Что-то пошло не так...", message: "Мы работаем над этим.")
                }
                
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        } else if editingStyle == .delete {
            NetworkManager.shared.leaveGroup(groupId: group.id) { [weak self] isSuccessful in
                self?.dismissLoadingView()
                
                if isSuccessful {
                    self?.presentAlert(message: "Вы покинули сообщество\n\"\(group.name)\".")
                    group.isMember = false
                } else {
                    self?.presentAlert(title: "Что-то пошло не так...", message: "Мы работаем над этим.")
                }
                
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}


//
// MARK: - UISearchBarDelegate
//
extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchQuery = searchBar.text, searchQuery != "" else { return }
        
        showLoadingView()
        NetworkManager.shared.searchGroups(searchQuery) { [weak self] searchResults in
            self?.dismissLoadingView()
            self?.searchResults = searchResults
            self?.tableView.reloadData()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
        tableView.reloadData()
    }
}
