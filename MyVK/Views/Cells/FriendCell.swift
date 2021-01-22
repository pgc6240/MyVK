//
//  FriendCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class FriendCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: MyImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    
    
    func set(with friend: User) {
        avatarImageView.downloadImage(with: friend.photoUrl)
        friendNameLabel.text = friend.firstName + " " + friend.lastName
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
    }
}
