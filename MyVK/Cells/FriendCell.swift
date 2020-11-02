//
//  FriendCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class FriendCell: UITableViewCell {
    
    static let reuseId = "FriendCell"
    
    
    func set(with friend: User) {
        imageView?.image    = UIImage(systemName: "person.fill")
        textLabel?.text     = "\(friend.firstName) \(friend.lastName)"
    }
}
