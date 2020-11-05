//
//  FriendCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class FriendCell: UITableViewCell {
    
    static let reuseId = "FriendCell"
    
    @IBOutlet weak var friendAvatarImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    
    
    func set(with friend: User) {
        
        friendNameLabel.text = friend.firstName + " " + friend.lastName
    }
}
