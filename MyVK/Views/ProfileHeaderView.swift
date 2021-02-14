//
//  ProfileHeaderView.swift
//  MyVK
//
//  Created by pgc6240 on 30.01.2021.
//

import UIKit

final class ProfileHeaderView: UIView {
    
    @IBOutlet weak var avatarImageView: MyImageView!
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
    
    
    func set(with owner: CanPost) {
        avatarImageView.downloadImage(with: owner.photoUrl)
        nameLabel.text = owner.name
        if let user = owner as? User {
            secondaryLabel.text = user.homeTown
            tertiaryLabel.text  = user.age
            friendsOrMembersLabel.text = "Друзья".localized
            groupsStackView.isHidden = false
            friendsOrMembersCountLabel.setTitle(String(user.friends.count), for: .normal)
            groupsCountLabel.setTitle(String(user.groups.count), for: .normal)
            photosCountLabel.setTitle(String(user.photos.count), for: .normal)
            wallPostsCountLabel.setTitle(String(user.posts.count), for: .normal)
        } else if let group = owner as? Group {
            secondaryLabel.text = (group.isOpen ? "Открытое" : "Закрытое").localized + " сообщество".localized
            tertiaryLabel.text = group.city
            friendsOrMembersLabel.text = "Участники".localized
            groupsStackView.isHidden = true
        }
        for countLabel in countLabels {
            if countLabel.titleLabel?.text != "" {
                countLabel.setTitleColor(.vkColor, for: .normal)
                countLabel.backgroundColor = .clear
            }
        }
    }
    
    
    func set(_ memberCount: Int?, _ photosCount: Int?, _ postsCount: Int?) {
        if memberCount == nil {
            friendsOrMembersStackView.isHidden = true
        }
        friendsOrMembersCountLabel.setTitle(F.fn(memberCount), for: .normal)
        photosCountLabel.setTitle(F.fn(photosCount), for: .normal)
        wallPostsCountLabel.setTitle(F.fn(postsCount), for: .normal)
    }
}
