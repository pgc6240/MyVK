//
//  CanPostCell.swift
//  MyVK
//
//  Created by pgc6240 on 17.02.2021.
//

import UIKit

final class CanPostCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: MyImageView!
    @IBOutlet weak var nameLabel: PlaceholderLabel!
    @IBOutlet weak var secondaryLabel: SecondaryPlaceholderLabel!
    
    var secondaryTextForUser: (User) -> String? = {
        $0.canAccessClosed ? ($0.homeTown ?? $0.age) : "Закрытый профиль".localized
    }
    
    var secondaryTextForGroup: (Group) -> String = {
        ($0.isOpen ? "Открытое" : "Закрытое").localized + " сообщество".localized
    }
    
    
    func set(with owner: CanPost) {
        avatarImageView.downloadImage(with: owner.photoUrl)
        nameLabel.text = owner.name
        if let user = owner as? User {
            secondaryLabel.text = secondaryTextForUser(user)
        } else if let group = owner as? Group {
            secondaryLabel.text = secondaryTextForGroup(group)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
    }
}
