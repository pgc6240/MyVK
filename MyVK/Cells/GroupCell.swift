//
//  GroupCell.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

import UIKit

final class GroupCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView:  PlaceholderImageView!
    @IBOutlet weak var groupNameLabel:   PlaceholderLabel!
    @IBOutlet weak var groupIsOpenLabel: SecondaryPlaceholderLabel!
    
    
    func set(with group: Group) {
        avatarImageView.downloadImage(with: group.photoUrl)
        groupNameLabel.text   = group.name
        groupIsOpenLabel.text = group.secondaryText
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
    }
}
