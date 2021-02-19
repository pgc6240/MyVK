//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import UIKit

protocol PostCellDelegate: class {
    func deletePost(postId: Int)
    func profileTapped(on post: Post)
    func photoTapped(on post: Post)
}

extension PostCellDelegate {
    func deletePost(postId: Int) {}
    func profileTapped(on post: Post) {}
}

final class PostCell: UITableViewCell {
    
    var post: Post!
    weak var delegate: PostCellDelegate?
    
    // MARK: - Subviews -
    @IBOutlet weak var profileStackView: UIStackView!
    @IBOutlet weak var avatarImageView: MyImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deletePostButton: UIButton!
    @IBOutlet weak var postTextView: PostTextView!
    @IBOutlet weak var photoImageView: MyImageView!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCountLabel: UIButton!

    
    // MARK: - Initialization -
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(removeImages), name: Notification.Name("PostsVC.viewDidDisappear"), object: nil)
    }
    
    
    // MARK: - Internal methods -
    override func awakeFromNib() {
        super.awakeFromNib()
        profileStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped)))
    }
    
    
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
        self.post = post
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
    
    
    func reloadImages() {
        avatarImageView.reloadImage()
        photoImageView.reloadImage()
    }
    
    
    // MARK: - Actions and segues -
    @IBAction func deletePost() {
        delegate?.deletePost(postId: post.id)
    }
    
    
    // MARK: - Gesture recognizers -
    @objc func photoTapped() {
        delegate?.photoTapped(on: post)
    }
    
    
    @objc func profileTapped() {
        delegate?.profileTapped(on: post)
    }
}
