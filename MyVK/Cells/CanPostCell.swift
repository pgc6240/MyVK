//
//  CanPostCell.swift
//  MyVK
//
//  Created by pgc6240 on 17.02.2021.
//

import UIKit

final class CanPostCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: PlaceholderImageView!
    @IBOutlet weak var nameLabel:       PlaceholderLabel!
    @IBOutlet weak var secondaryLabel:  SecondaryPlaceholderLabel!
    

    func set(with owner: CanPost) {
        avatarImageView.downloadImage(with: owner.photoUrl)
        nameLabel.text      = owner.name
        secondaryLabel.text = owner.secondaryText
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
    }
}
