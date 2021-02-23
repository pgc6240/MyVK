//
//  GroupCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class GroupCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: PlaceholderImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupIsPublicLabel: UILabel!
    
    
    func set(with group: Group) {
        avatarImageView.downloadImage(with: group.photoUrl)
        groupNameLabel.text = group.name
        groupIsPublicLabel.text = (group.isOpen ? "Открытое" : "Закрытое").localized + " сообщество".localized
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
    }
}
