//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import UIKit

protocol PostCellDelegate: class {
    func deletePost(postId: Int)
}

final class PostCell: UITableViewCell {
    
    var postId: Int!
    weak var delegate: PostCellDelegate?
    
    // MARK: - Subviews -
    @IBOutlet weak var avatarImageView: MyImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deletePostButton: UIButton!
    @IBOutlet weak var postTextView: PostTextView!
    @IBOutlet weak var photoImageView: MyImageView!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCountLabel: UIButton!

    
    // MARK: - Initialization -
    //required init?(coder: NSCoder) {
        //super.init(coder: coder)
        //NotificationCenter.default.addObserver(self, selector: #selector(removeImages), name: Notification.Name("PostsVC.viewDidDisappear"), object: nil)
    //}
    
    
    // MARK: - Internal methods -
    @objc private func removeImages() {
        avatarImageView.prepareForReuse()
        photoImageView.prepareForReuse()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
        photoImageView.prepareForReuse()
        photoImageView.isHidden = false
        viewCountLabel.isHidden = false
    }
    
    
    private func layoutPhotos(_ photos: [Photo]) {
        if photos.isEmpty {
            photoImageView.prepareForReuse()
            photoImageView.isHidden = true
            return
        }
        photoImageView.downloadImage(with: photos.first?.maxSizeUrl)
    }
    
    
    // MARK: - External methods -
    func set(with post: Post, and owner: CanPost? = nil) {
        postId = post.id
        avatarImageView.downloadImage(with: post.userOwner?.photoUrl ?? post.groupOwner?.photoUrl ?? owner?.photoUrl)
        nameLabel.text = post.userOwner?.name ?? post.groupOwner?.name ?? owner?.name
        dateLabel.text = F.fd(post.date)
        deletePostButton.isHidden = owner !== User.current
        postTextView.text = "\(post.text ?? "") \(post.attachmentsString ?? "")"
        layoutPhotos(Array(post.photos))
        likeButton.set(likeCount: post.likeCount, liked: post.likedByCurrentUser, postId: post.id)
        viewCountLabel.setTitle(post.viewCount, for: .normal)
        viewCountLabel.isHidden = post.viewCount == nil
    }
    
    
    @IBAction func deletePost() {
        delegate?.deletePost(postId: postId)
    }
}
