//
//  FriendCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class FriendCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: MyImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    
    
    func set(with friend: User) {
        avatarImageView.downloadImage(with: friend.photoUrl)
        nameLabel.text = friend.name
        secondaryLabel.text = {
            if friend.canAccessClosed {
                return friend.homeTown ?? friend.age
            } else {
                return "Закрытый профиль".localized
            }
        }()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
    }
}
