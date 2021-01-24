//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import UIKit

final class PostCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: MyImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCountLabel: UIButton!
    
    
    func set(with post: Post, ownerPhotoUrl: String?, and ownerName: String) {
        avatarImageView.downloadImage(with: ownerPhotoUrl)
        avatarImageView.contentMode = ownerPhotoUrl == "" ? .center : .scaleAspectFit
        nameLabel.text = ownerName
        dateLabel.text = F.fd(post.date)
        postTextLabel.text = post.text
        likeButton.set(likeCount: post.likeCount, liked: post.likedByCurrentUser, postId: post.id)
        viewCountLabel.setTitle(post.viewCount, for: .normal)
        if post.viewCount == nil {
            viewCountLabel.isHidden = true
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewCountLabel.isHidden = false
    }
}
