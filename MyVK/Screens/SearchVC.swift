//
//  SearchVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

final class SearchVC: UITableViewController {

    var searchResults: [Group] = [] { didSet { tableView.reloadData() }}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
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
        
        let group = searchResults[indexPath.row]
        
        showLoadingView()
        NetworkManager.shared.joinGroup(groupId: group.id) { [weak self] isSuccessful in
            self?.dismissLoadingView()
            
            if isSuccessful {
                self?.presentAlert(title: "Hooray! 🎉", message: "\nВы теперь состоите в сообществе\n\"\(group.name)\".")
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
        
        showLoadingView()
        NetworkManager.shared.searchGroups(searchQuery) { [weak self] searchResults in
            self?.dismissLoadingView()
            self?.searchResults = searchResults
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
    }
}
