//
//  FriendCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class FriendCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: PlaceholderImageView!
    @IBOutlet weak var nameLabel:       PlaceholderLabel!
    @IBOutlet weak var secondaryLabel:  SecondaryPlaceholderLabel!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(prepareForReuse),
                                               name: Notifications.friendsVCviewWillDisappear.name,
                                               object: nil)
    }
    
    
    func set(with friend: User) {
        avatarImageView.downloadImage(with: friend.photoUrl)
        nameLabel.text      = friend.name
        secondaryLabel.text = friend.secondaryText
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
    }
}
