//
//  GroupsVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit
import RealmSwift

final class GroupsVC: UITableViewController {
    
    var groups: List<Group> = User.current.groups
    private var notificationToken: NotificationToken?
    private var backingStore: List<Group> { User.current.groups }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableViewController()
        configureSearchController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGroups()
    }
    
    
    private func configureTableViewController() {
        navigationItem.leftBarButtonItem = editButtonItem
        PersistenceManager.pair(groups, with: tableView, token: &notificationToken)
    }
    
    
    func loadGroups() {
        NetworkManager.shared.getGroups { groups in
            PersistenceManager.save(groups, in: User.current.groups)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
           let groupDetailVC = segue.destination as? GroupDetailVC {
            let group = groups[indexPath.row]
            groupDetailVC.group = group
        }
    }
    
    
    deinit {
        notificationToken?.invalidate()
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
        let groupToDelete = groups[indexPath.row]
        
        showLoadingView()
        NetworkManager.shared.leaveGroup(groupId: groupToDelete.id) { [weak self] isSuccessful in
            self?.dismissLoadingView()
            
            if isSuccessful {
                PersistenceManager.delete(groupToDelete)
                self?.presentAlert(message: "Вы покинули сообщество".localized + "\n\"\(groupToDelete.name)\".".localized)
            } else {
                self?.presentAlert(title: "Что-то пошло не так...", message: "Мы работаем над этим.")
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
extension GroupsVC: UISearchBarDelegate {
    
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
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            groups = backingStore
        } else {
            groups = backingStore.filter("name CONTAINS[cd] %@", searchText).list
        }
        tableView.reloadSections([0], with: .automatic)
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        groups = backingStore
        tableView.reloadSections([0], with: .automatic)
    }
}
