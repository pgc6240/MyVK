//
//  FriendCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

class FriendCell: UITableViewCell {
    
    static let reuseId = "FriendCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    func set(with friend: User) {
        nameLabel.text = "\(friend.firstName) \(friend.lastName)"
    }
}
