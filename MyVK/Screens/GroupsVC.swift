//
//  GroupsVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

final class GroupsVC: UITableViewController {
    
    var groups: [Group] = []
    private lazy var backingStore: [Group] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        configureSearchController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGroups()
    }
    
    
    private func configureSearchController() {
        let searchController                                  = UISearchController()
        searchController.searchBar.delegate                   = self
        searchController.searchBar.placeholder                = "Поиск в моих сообществах".localized
        searchController.searchBar.autocorrectionType         = .no
        searchController.searchBar.autocapitalizationType     = .sentences
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false
    }
    
    
    func loadGroups() {
        NetworkManager.shared.getGroups { [weak self] groups in
            self?.updateGroups(with: groups)
        }
    }
    
    
    private func updateGroups(with groups: [Group]) {
        let groupsUpdated = self.groups.updating(with: groups)
        if groupsUpdated {
            backingStore = groups
            tableView.reloadSections([0], with: .automatic)
        }
    }
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource
//
extension GroupsVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        groups.isEmpty ? "Нет сообществ".localized : "Мои сообщества".localized
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.reuseId) as! GroupCell
        let group = groups[indexPath.row]
        cell.set(with: group)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        
        showLoadingView()
        NetworkManager.shared.leaveGroup(groupId: group.id) { [weak self] isSuccessful in
            self?.dismissLoadingView()
            
            if isSuccessful {
                let removedGroup = self?.groups.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections([0], with: .automatic)
                self?.presentAlert(message: "Вы покинули сообщество".localized + "\n\"\(group.name)\".".localized)
                PersistenceManager.delete([removedGroup])
            } else {
                self?.presentAlert(title: "Что-то пошло не так...", message: "Мы работаем над этим.")
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "Выйти из сообщества".localized
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedGroup = groups.remove(at: sourceIndexPath.row)
        groups.insert(movedGroup, at: destinationIndexPath.row)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
}


//
// MARK: - UISearchBarDelegate
//
extension GroupsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            groups = backingStore
        } else {
            groups = backingStore.filter { group in
                var match = false
                let wordsInSearchQuery = searchText.split(separator: " ")
                for word in wordsInSearchQuery {
                    guard !match else { break }
                    match = group.name.lowercased().contains(word.lowercased())
                }
                return match
            }
        }
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        groups = backingStore
        tableView.reloadData()
    }
}
