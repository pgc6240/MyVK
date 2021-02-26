//
//  ProfileHeaderView.swift
//  MyVK
//
//  Created by pgc6240 on 30.01.2021.
//

import UIKit

final class ProfileHeaderView: UIView {
    
    @IBOutlet weak var avatarImageView: ShadowedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var tertiaryLabel: UILabel!
    
    @IBOutlet weak var friendsOrMembersStackView: UIStackView!
    @IBOutlet weak var friendsOrMembersLabel: UILabel!
    @IBOutlet weak var groupsStackView: UIStackView!
    
    @IBOutlet weak var friendsOrMembersCountLabel: UIButton!
    @IBOutlet weak var groupsCountLabel: UIButton!
    @IBOutlet weak var photosCountLabel: UIButton!
    @IBOutlet weak var wallPostsCountLabel: UIButton!
    
    @IBOutlet var countLabels: [UIButton]!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(removeImages), name: Notifications.postsVCviewWillDisappear.name, object: nil)
    }
    
    
    @objc private func removeImages() {
        avatarImageView.prepareForReuse()
    }
    
    
    func set(with owner: CanPost?) {
        avatarImageView.downloadImage(with: owner?.photoUrl)
        nameLabel.text = owner?.name
        if let user = owner as? User {
            secondaryLabel.text = user.homeTown
            tertiaryLabel.text  = user.age
            friendsOrMembersLabel.text = "Друзья".localized
            groupsStackView.isHidden = false
            UIView.transition(with: self, duration: 0.6, options: [.allowUserInteraction, .transitionCrossDissolve]) {
                [weak self] in
                self?.friendsOrMembersCountLabel.setTitle(String(user.friendsCount), for: .normal)
                self?.groupsCountLabel.setTitle(String(user.groupsCount), for: .normal)
                self?.photosCountLabel.setTitle(String(user.photosCount), for: .normal)
                self?.wallPostsCountLabel.setTitle(String(user.postsCount), for: .normal)
            }
        } else if let group = owner as? Group {
            secondaryLabel.text = (group.isOpen ? "Открытое" : "Закрытое").localized + " сообщество".localized
            tertiaryLabel.text = group.city
            friendsOrMembersLabel.text = "Участники".localized
            groupsStackView.isHidden = true
            if group.membersCount == -1 {
                friendsOrMembersStackView.isHidden = true
            }
            friendsOrMembersCountLabel.isEnabled = false
            UIView.transition(with: self, duration: 0.6, options: [.allowUserInteraction, .transitionCrossDissolve]) {
                [weak self] in
                self?.friendsOrMembersCountLabel.setTitle(F.fn(group.membersCount), for: .normal)
                self?.photosCountLabel.setTitle(F.fn(group.photosCount), for: .normal)
                self?.wallPostsCountLabel.setTitle(F.fn(group.postsCount), for: .normal)
            }
        }
        for countLabel in countLabels {
            if countLabel.titleLabel?.text != "" {
                if countLabel != friendsOrMembersCountLabel {
                    countLabel.isEnabled = countLabel.currentTitle != "0"
                }
                countLabel.setTitleColor(countLabel.isEnabled ? .vkColor : .label, for: .normal)
                countLabel.backgroundColor = .clear
            }
        }
    }
}
