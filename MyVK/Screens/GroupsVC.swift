//
//  GroupsVC.swift
//  MyVK
//
//  Created by pgc6240 on 27.10.2020.
//

import UIKit

class GroupsVC: UITableViewController {
    
    var user: User?
    var groups: [Group] = []
    
    let sectionHeaders = ["Добавить новое сообщество", "Мои сообщества"]
    var newGroupTitle = "Новое сообщество..."
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        loadGroups(for: user)
    }
    
    
    func loadGroups(for user: User?) {
        groups = makeDummyGroups()
    }
}


//
// MARK: - UITableViewDelegate & UITableViewDataSource
//
extension GroupsVC {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        isEditing ? sectionHeaders[section] : nil
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        isEditing ? 2 : 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEditing {
            return section == 0 ? 1 : groups.count
        } else {
            return groups.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.isEditing && indexPath == [0,0] {
            return tableView.dequeueReusableCell(withIdentifier: "NewGroupCell", for: indexPath)
            
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
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if indexPath == [0,0] {
            return .insert
        } else {
            return .delete
        }
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        editing ? tableView.insertSections([0], with: .automatic) : tableView.deleteSections([0], with: .automatic)
        tableView.reloadSections([0], with: .automatic)
    }
}


//
// MARK: - UITextFieldDelegate
//
extension GroupsVC: UITextFieldDelegate {
 
    @IBAction func editingChanged(_ textField: UITextField) {
        guard let text = textField.text, text != "" else { return }
        newGroupTitle = text
    }
}


//
// MARK: - Dummy data
//
func makeDummyGroups() -> [Group] {
    var groups: [Group] = []
    for i in 0...Int.random(in: 1...100) {
        groups.append(Group(name: "Сообщество \(i)"))
    }
    return groups
}
