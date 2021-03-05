//
//  ProfileHeaderView.swift
//  MyVK
//
//  Created by pgc6240 on 30.01.2021.
//

import UIKit

final class ProfileHeaderView: UIView {
    
    // MARK: - Avatar and labels
    @IBOutlet weak var avatarImageView:             ShadowedImageView!
    @IBOutlet weak var nameLabel:                   UILabel!
    @IBOutlet weak var secondaryLabel:              UILabel!
    @IBOutlet weak var tertiaryLabel:               UILabel!
    
    // MARK: - Container subviews
    @IBOutlet weak var friendsOrMembersStackView:   UIStackView!
    @IBOutlet weak var friendsOrMembersLabel:       UILabel!
    @IBOutlet weak var groupsStackView:             UIStackView!
    
    // MARK: - Counter subviews
    @IBOutlet weak var friendsOrMembersCountLabel:  UIButton!
    @IBOutlet weak var groupsCountLabel:            UIButton!
    @IBOutlet weak var photosCountLabel:            UIButton!
    @IBOutlet weak var wallPostsCountLabel:         UIButton!
    @IBOutlet var countLabels:                     [UIButton]!
    
    
    // MARK: - Initialization -
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeImages),
                                               name: Notifications.postsVCviewWillDisappear.name,
                                               object: nil)
    }
    
    
    // MARK: - Internal methods -
    @objc private func removeImages() {
        avatarImageView.prepareForReuse()
    }
    
    
    private func configureCountLabels() {
        countLabels.forEach {
            $0.isEnabled = ($0.currentTitle != "0" && $0.currentTitle != "-1")
            $0.setTitleColor($0.isEnabled ? .vkColor : .label, for: .normal)
            $0.backgroundColor = .clear
        }
    }
    
    
    // MARK: - External methods -
    func configure(with owner: CanPost?) {
        avatarImageView.downloadImage(with: owner?.photoUrl)
        nameLabel.text = owner?.name
        if let user = owner as? User {
            configure(with: user)
        } else if let group = owner as? Group {
            configure(with: group)
        }
        configureCountLabels()        
    }
    
    
    func configure(with user: User) {
        secondaryLabel.text        = user.homeTown
        tertiaryLabel.text         = user.age
        friendsOrMembersLabel.text = "Друзья".localized
        groupsStackView.isHidden   = false
        UIView.transition(with: self, duration: 0.6, options: [.allowUserInteraction, .transitionCrossDissolve]) {
            [weak self] in
            self?.friendsOrMembersCountLabel.setTitle(String(user.friendsCount), for: .normal)
            self?.groupsCountLabel.setTitle(String(user.groupsCount), for: .normal)
            self?.photosCountLabel.setTitle(String(user.photosCount), for: .normal)
            self?.wallPostsCountLabel.setTitle(String(user.postsCount), for: .normal)
        }
    }
    
    
    func configure(with group: Group) {
        secondaryLabel.text                  = group.secondaryText
        tertiaryLabel.text                   = group.city
        friendsOrMembersLabel.text           = "Участники".localized
        groupsStackView.isHidden             = true
        friendsOrMembersCountLabel.isEnabled = false
        UIView.transition(with: self, duration: 0.6, options: [.allowUserInteraction, .transitionCrossDissolve]) {
            [weak self] in
            self?.friendsOrMembersCountLabel.setTitle(F.fn(group.membersCount), for: .normal)
            self?.photosCountLabel.setTitle(F.fn(group.photosCount), for: .normal)
            self?.wallPostsCountLabel.setTitle(F.fn(group.postsCount), for: .normal)
        }
    }
}
