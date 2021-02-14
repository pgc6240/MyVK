//
//  GroupsVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit
import RealmSwift

final class GroupsVC: UITableViewController {
    
    var user: User! = User.current
    lazy var groups = user.groups
    private var notificationToken: NotificationToken?
    private var backingStore: List<Group> { user.groups }
    
    
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
        PersistenceManager.pair(groups, with: tableView, token: &notificationToken)
        if user == User.current {
            if navigationController?.title != "ProfileNC" {
                navigationItem.leftBarButtonItem = editButtonItem
            }
        } else {
            title = user.name
        }
    }
    
    
    func loadGroups() {
        NetworkManager.shared.getGroups(userId: user.id) { [weak self] groups in
            PersistenceManager.save(groups, in: self?.user.groups)
        }
    }
    
    
    func joinGroup(_ group: Group, onSuccess: @escaping () -> Void = {}) {
        showLoadingView()
        NetworkManager.shared.joinGroup(groupId: group.id) { [weak self] isSuccessful in
            self?.dismissLoadingView()
            
            if isSuccessful {
                self?.presentAlert(title: "\nВы теперь состоите в сообществе".localized + "\n\"\(group.name)\".".localized)
                onSuccess()
            } else {
                self?.presentFailureAlert()
            }
        }
    }
    
    
    func leaveGroup(_ group: Group, onSuccess: @escaping () -> Void = {}) {
        showLoadingView()
        NetworkManager.shared.leaveGroup(groupId: group.id) { [weak self] isSuccessful in
            self?.dismissLoadingView()
            
            if isSuccessful {
                self?.presentAlert(title: "Вы покинули сообщество".localized + "\n\"\(group.name)\".".localized)
                PersistenceManager.delete(group)
                onSuccess()
            } else {
                self?.presentFailureAlert()
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
           let profileVC = segue.destination as? PostsVC,
           let group = PersistenceManager.create(groups[indexPath.row]) {
            
            profileVC.owner = group
        }
    }
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource -
//
extension GroupsVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if groups.isEmpty {
            return "Нет сообществ".localized
        } else if user == User.current {
            return "Мои сообщества".localized
        } else if Locale.isEnglishLocale {
            return "Communities"
        } else {
            return "Cообщества ".localized + user.nameGen
        }
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
        let groupToLeave = groups[indexPath.row]
        leaveGroup(groupToLeave)
    }
    
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "Выйти из сообщества".localized
    }
}


//
// MARK: - UISearchBarDelegate -
//
extension GroupsVC: UISearchBarDelegate {
    
    private func configureSearchController() {
        let searchController                                  = UISearchController()
        searchController.searchBar.delegate                   = self
        searchController.searchBar.autocorrectionType         = .no
        searchController.searchBar.autocapitalizationType     = .sentences
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false
        
        if user == User.current {
            searchController.searchBar.placeholder = "Искать в моих сообществах".localized
        } else if Locale.isEnglishLocale {
            searchController.searchBar.placeholder = "Search in user's commutities"
        } else {
            searchController.searchBar.placeholder = "Искать в сообществах \(user.nameGen)"
        }
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
