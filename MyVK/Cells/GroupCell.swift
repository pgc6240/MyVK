//
//  GroupCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

class GroupCell: UITableViewCell {

    static let reuseId = "GroupCell"
    
    func set(with group: Group) {
        imageView?.image    = UIImage(systemName: "people.3")
        textLabel?.text     = group.name
    }
}
