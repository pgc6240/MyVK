//
//  GroupsVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

final class GroupsVC: UITableViewController {
    
    var user: User?
    var groups: [Group] = []
    lazy var backingStore: [Group] = []
    
    let sectionTitles   = ["Добавить новое сообщество", "Мои сообщества"].localized
    var newGroupTitle   = "Новое сообщество".localized + " \(Int.random(in: 100..<1000))"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        configureSearchController()
        loadGroups(for: user)
    }
    
    
    func loadGroups(for user: User?) {
        (1...Int.random(in: 2...100)).forEach { groups.append(Group(name: "Сообщество".localized + " \($0)")) }
        backingStore = groups
    }
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource
//
extension GroupsVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        isEditing ? sectionTitles[section] : sectionTitles[1]
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        isEditing ? 2 : 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isEditing ? (section == 0 ? 1 : groups.count) : groups.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.isEditing && indexPath == [0,0] {
            let newGroupCell = tableView.dequeueReusableCell(withIdentifier: "NewGroupCell", for: indexPath)
            newGroupCell.imageView?.image = UIImage(systemName: "person.3.fill")
            newGroupCell.imageView?.preferredSymbolConfiguration = .init(scale: .medium)
            if let newGroupTextField = newGroupCell.viewWithTag(1001) as? UITextField {
                newGroupTitle = "Новое сообщество".localized + " \(Int.random(in: 100..<1000))"
                newGroupTextField.text = newGroupTitle
            }
            return newGroupCell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.reuseId) as! GroupCell
            let group = groups[indexPath.row]
            cell.set(with: group)
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            groups.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            let newGroup = Group(name: newGroupTitle)
            groups.insert(newGroup, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        indexPath == [0,0] ? .insert : .delete
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        editing ? tableView.insertSections([0], with: .automatic) : tableView.deleteSections([0], with: .automatic)
        tableView.reloadSections([0], with: .automatic)
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        nil
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movedGroup = groups.remove(at: sourceIndexPath.row)
        groups.insert(movedGroup, at: destinationIndexPath.row)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        indexPath == [0,0] ? false : true
    }
}


//
// MARK: - UITextFieldDelegate
//
extension GroupsVC: UITextFieldDelegate {
 
    @IBAction func editingChanged(_ textField: UITextField) {
        guard let text = textField.text, text != "" else {
            newGroupTitle = "Новое сообщество".localized + " \(Int.random(in: 100..<1000))"
            return
        }
        newGroupTitle = text
    }
}


//
// MARK: - UISearchBarDelegate
//
extension GroupsVC: UISearchBarDelegate {
    
    private func configureSearchController() {
        let searchController                                    = UISearchController()
        searchController.searchBar.delegate                     = self
        searchController.searchBar.placeholder                  = "Поиск в моих сообществах".localized
        searchController.searchBar.autocapitalizationType       = .sentences
        searchController.obscuresBackgroundDuringPresentation   = false
        navigationItem.searchController                         = searchController
        navigationItem.hidesSearchBarWhenScrolling              = false
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchText.isEmpty ? (groups = backingStore) : (groups = backingStore.filter { $0.name.lowercased().contains(searchText.lowercased()) })
        tableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
