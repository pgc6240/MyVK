//
//  GroupCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class GroupCell: UITableViewCell {
    static let reuseId = String(describing: GroupCell.self)
    
    
    func set(with group: Group) {
        textLabel?.text = group.name
    }
}
