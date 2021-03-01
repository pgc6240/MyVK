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
    
    private let verticalInset:   CGFloat = 11
    private let horizontalInset: CGFloat = 16
    private let verticalSpacing: CGFloat = 2
    
    
    // MARK: - Initialization -
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(prepareForReuse),
                                               name: Notifications.friendsVCviewWillDisappear.name,
                                               object: nil)
    }
}
    
 
// MARK: - Cell's lifecycle -
extension FriendCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints       = false
        secondaryLabel.translatesAutoresizingMaskIntoConstraints  = false
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.frame = getAvatarImageViewFrame()
        nameLabel.frame       = getNameLabelFrame()
        secondaryLabel.frame  = getSecondaryLabelFrame()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
    }
}
    
    
// MARK: - External methods -
extension FriendCell {
    
    func set(with friend: User) {
        avatarImageView.downloadImage(with: friend.photoUrl)
        nameLabel.text      = friend.name
        secondaryLabel.text = friend.secondaryText
    }
}
    
    
// MARK: - Internal methods -
private extension FriendCell {
    
    func getAvatarImageViewFrame() -> CGRect {
        return CGRect(x: horizontalInset, y: verticalInset, width: 60, height: 60)
    }
        
    
    func getNameLabelFrame() -> CGRect {
        guard let text = nameLabel.text else { return .zero }
        let maxTextWidth        = bounds.width - avatarImageView.bounds.width - horizontalInset * 3
        let secondaryTextHeight = secondaryLabel.text == nil ? 0 : secondaryLabel.font.capHeight
        let nameLabelOriginX    = avatarImageView.frame.maxX + horizontalInset
        let nameLabelOriginY    = avatarImageView.frame.midY - nameLabel.font.capHeight - secondaryTextHeight
        let nameLabelOrigin     = CGPoint(x: ceil(nameLabelOriginX), y: ceil(nameLabelOriginY))
        let nameLabelSize       = text.size(maxWidth: maxTextWidth, font: nameLabel.font)
        return CGRect(origin: nameLabelOrigin, size: nameLabelSize)
    }
    
    
    func getSecondaryLabelFrame() -> CGRect {
        guard let text = secondaryLabel.text else { return .zero }
        let maxTextWidth          = bounds.width - avatarImageView.bounds.width - horizontalInset * 3
        let secondaryLabelOriginX = avatarImageView.frame.maxX + horizontalInset
        let secondaryLabelOriginY = avatarImageView.frame.midY + verticalSpacing
        let secondaryLabelOrigin  = CGPoint(x: ceil(secondaryLabelOriginX), y: ceil(secondaryLabelOriginY))
        let secondaryLabelSize    = text.size(maxWidth: maxTextWidth, font: secondaryLabel.font)
        return CGRect(origin: secondaryLabelOrigin, size: secondaryLabelSize)
    }
}
