//
//  FriendCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class FriendCell: UITableViewCell {
    static let reuseId = String(describing: FriendCell.self)
    
    @IBOutlet weak var avatarImageView: MyImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
    }
    
    
    func set(with friend: User) {
        avatarImageView.downloadImage(url: friend.photoMax)
        friendNameLabel.text = friend.firstName + " " + friend.lastName
    }
}
