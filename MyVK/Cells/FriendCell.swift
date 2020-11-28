//
//  FriendCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class FriendCell: UITableViewCell {
    static let reuseId = String(describing: FriendCell.self)
    
    @IBOutlet weak var friendNameLabel: UILabel!
    
    
    func set(with friend: User) {
        friendNameLabel.text = friend.firstName + " " + friend.lastName
    }
}
