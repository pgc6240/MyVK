//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import UIKit
import RealmSwift

final class PostCell: UITableViewCell {
    
    var postId: Int!
    weak var parent: UIViewController?
    
    @IBOutlet weak var avatarImageView: MyImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCountLabel: UIButton!
    @IBOutlet weak var deletePostButton: UIButton!
    @IBOutlet weak var photoImageView: MyImageView!
    
    
    func set(with post: Post, and owner: CanPost) {
        postId = post.id
        avatarImageView.downloadImage(with: owner.photoUrl)
        avatarImageView.contentMode = owner.photoUrl == "" ? .center : .scaleAspectFit
        nameLabel.text = owner.name
        dateLabel.text = F.fd(post.date)
        likeButton.set(likeCount: post.likeCount, liked: post.likedByCurrentUser, postId: post.id)
        viewCountLabel.setTitle(post.viewCount, for: .normal)
        let attachmentsString = "[\(post.attachments.map { $0.type }.joined(separator: ", "))]".uppercased()
        postTextLabel.text = (post.text.isEmpty ? "" : "\(post.text)") + (!post.text.isEmpty && !post.attachments.isEmpty ? "\n" : "") + (post.attachments.isEmpty ? "" : attachmentsString)
        if post.viewCount == nil { viewCountLabel.isHidden = true }
        if owner !== User.current { deletePostButton.isHidden = true }
        let photos: [Photo] = post.attachments.compactMap { $0.photo }
        layoutPhotos(photos)
    }
    
    
    private func layoutPhotos(_ photos: [Photo]) {
        if photos.isEmpty {
            photoImageView.isHidden = true
            return
        }

        guard let firstPhoto = photos.first else { return }
        photoImageView.downloadImage(with: firstPhoto.maxSizeUrl)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
        photoImageView.prepareForReuse()
        viewCountLabel.isHidden = false
        photoImageView.isHidden = false
    }
    
    
    @IBAction func deletePost() {
        (parent as? ProfileVC)?.deletePost(with: postId)
    }
}
