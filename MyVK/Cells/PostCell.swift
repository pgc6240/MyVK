//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import UIKit

final class PostCell: UITableViewCell {
    
    private var postId: Int!
    weak var postsVC: PostsVC?
    
    @IBOutlet weak var avatarImageView: MyImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCountLabel: UIButton!
    
    
    func set(with post: Post, ownerPhotoUrl: String?, and ownerName: String) {
        postId = post.id
        avatarImageView.downloadImage(with: ownerPhotoUrl)
        avatarImageView.contentMode = ownerPhotoUrl == "" ? .center : .scaleAspectFit
        nameLabel.text = ownerName
        dateLabel.text = F.fd(post.date)
        likeButton.set(likeCount: post.likeCount, liked: post.likedByCurrentUser, postId: post.id)
        viewCountLabel.setTitle(post.viewCount, for: .normal)
        if post.viewCount == nil { viewCountLabel.isHidden = true }
        let attachmentsString = "[\(post.attachments.map { $0.type }.joined(separator: ", "))]".uppercased()
        postTextLabel.text = (post.text.isEmpty ? "" : "\(post.text)") + (!post.text.isEmpty && !post.attachments.isEmpty ? "\n" : "") + (post.attachments.isEmpty ? "" : attachmentsString)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
        viewCountLabel.isHidden = false
    }
    
    
    @IBAction func deletePost() {
        postsVC?.deletePost(with: postId)
    }
}
