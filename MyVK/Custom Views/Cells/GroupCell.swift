//
//  GroupCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class GroupCell: UITableViewCell {
    
    static let reuseId = "GroupCell"
    
    
    func set(with group: Group) {
        imageView?.image    = Images.group
        textLabel?.text     = group.name
    }
}
