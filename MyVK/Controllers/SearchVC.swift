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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
           let groupDetailVC = segue.destination as? GroupVC {
            let group = searchResults[indexPath.row]
            groupDetailVC.group = PersistenceManager.create(group)
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
        return !isLoading
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let group = searchResults[indexPath.row]
        
        showLoadingView()
        if editingStyle == .insert {
            NetworkManager.shared.joinGroup(groupId: group.id) { [weak self] isSuccessful in
                self?.dismissLoadingView()
                if isSuccessful {
                    group.isMember = true
                    self?.tableView.reloadRows(at: [indexPath], with: .right)
                    let message = "\nВы теперь состоите в сообществе".localized + "\n\"\(group.name)\".".localized
                    self?.presentAlert(title: "Hooray! 🎉", message: message)
                } else {
                    self?.presentAlert(title: "Что-то пошло не так...", message: "Мы работаем над этим.")
                }
            }
        } else if editingStyle == .delete {
            NetworkManager.shared.leaveGroup(groupId: group.id) { [weak self] isSuccessful in
                self?.dismissLoadingView()
                if isSuccessful {
                    group.isMember = false
                    self?.tableView.reloadRows(at: [indexPath], with: .left)
                    self?.presentAlert(title: "Вы покинули сообщество".localized + "\n\"\(group.name)\".".localized)
                } else {
                    self?.presentAlert(title: "Что-то пошло не так...", message: "Мы работаем над этим.")
                }
            }
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchQuery = searchBar.text, searchQuery != "" else { return }
        
        showLoadingView()
        NetworkManager.shared.searchGroups(searchQuery) { [weak self] searchResults in
            self?.dismissLoadingView()
            self?.searchResults = searchResults
            self?.tableView.reloadSections([0], with: .automatic)
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
        tableView.reloadData()
    }
}
