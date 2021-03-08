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
}


// MARK: - External methods -
extension ProfileHeaderView {
    
    func set(with owner: CanPost?) {
        avatarImageView.downloadImage(with: owner?.photoUrl)
        nameLabel.text = owner?.name
        if let user = owner as? User {
            set(with: user)
        } else if let group = owner as? Group {
            set(with: group)
        }
        configureCountLabels()
    }
}


// MARK: - Internal methods -
private extension ProfileHeaderView {
    
    @objc func removeImages() {
        avatarImageView.prepareForReuse()
    }
    
    
    func set(with user: User) {
        secondaryLabel.text        = user.homeTown
        tertiaryLabel.text         = user.age
        friendsOrMembersLabel.text = "Друзья".localized
        groupsStackView.isHidden   = false
        UIView.transition(with: self, duration: 0.6, options: [.allowUserInteraction, .transitionCrossDissolve]) {
            [weak self] in
            if user.friendsCount != -1 {
                self?.friendsOrMembersCountLabel.setTitle(String(user.friendsCount), for: .normal)
            }
            if user.groupsCount  != -1 {
                self?.groupsCountLabel.setTitle(String(user.groupsCount), for: .normal)
            }
            if user.photosCount  != -1 {
                self?.photosCountLabel.setTitle(String(user.photosCount), for: .normal)
            }
            if user.postsCount   != -1 {
                self?.wallPostsCountLabel.setTitle(String(user.postsCount), for: .normal)
            }
        }
    }
    
    
    func set(with group: Group) {
        secondaryLabel.text                  = group.secondaryText
        tertiaryLabel.text                   = group.city
        friendsOrMembersLabel.text           = "Участники".localized
        groupsStackView.isHidden             = true
        friendsOrMembersCountLabel.isEnabled = false
        UIView.transition(with: self, duration: 0.6, options: [.allowUserInteraction, .transitionCrossDissolve]) {
            [weak self] in
            if group.membersCount != -1 {
                self?.friendsOrMembersCountLabel.setTitle(F.fn(group.membersCount), for: .normal)
            }
            if group.photosCount  != -1 {
                self?.photosCountLabel.setTitle(F.fn(group.photosCount), for: .normal)
            }
            if group.postsCount   != -1 {
                self?.wallPostsCountLabel.setTitle(F.fn(group.postsCount), for: .normal)
            }
        }
    }
    
    
    func configureCountLabels() {
        countLabels.forEach {
            $0.isEnabled = ($0.currentTitle != "0" && $0.currentTitle != "-1")
            $0.setTitleColor($0.isEnabled ? .vkColor : .label, for: .normal)
            $0.backgroundColor = .clear
        }
    }
}
