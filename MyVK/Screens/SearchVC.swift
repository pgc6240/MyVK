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
        configureSearchController()
        (1...Int.random(in: 2...100)).forEach { searchResults.append(Group(id: $0, name: "Сообщество".localized + " \($0)")) }
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
        let cell  = tableView.dequeueReusableCell(withIdentifier: GroupCell.reuseId) as! GroupCell
        let group = searchResults[indexPath.row]
        cell.set(with: group)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let group = searchResults[indexPath.row]
        NetworkManager.shared.joinGroup(groupId: group.id) { [weak self] isSuccessful in
            if isSuccessful {
                self?.presentAlert(title: "Hooray! 🎉", message: "Вы теперь состоите в сообществе \(group.name).")
            } else {
                self?.presentAlert(title: "Что-то пошло не так...", message: "Мы работаем над этим.")
            }
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
        searchController.searchBar.placeholder                = "Поиск сообществ".localized
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchQuery = searchBar.text, searchQuery != "" else { return }
        NetworkManager.shared.searchGroups(searchQuery) { [weak self] searchResults in
            guard let self = self else { return }
            
            self.searchResults = searchResults
            self.tableView.reloadData()
        }
    }
}
