//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 22.12.2020.
//

import UIKit

final class PostCell: UITableViewCell {
    
    var post:           Post?
    weak var delegate:  PostCellDelegate?
    
    // MARK: - Subviews -
    @IBOutlet weak var profileStackView: UIStackView!
    @IBOutlet weak var avatarImageView:  PlaceholderImageView!
    @IBOutlet weak var nameLabel:        PlaceholderLabel!
    @IBOutlet weak var dateLabel:        SecondaryPlaceholderLabel!
    @IBOutlet weak var deletePostButton: EnlargedButton!
    @IBOutlet weak var postTextView:     PostTextView!
    @IBOutlet weak var photoImageView:   PlaceholderImageView!
    @IBOutlet weak var likeButton:       LikeButton!
    @IBOutlet weak var viewCountLabel:   UIButton!

    
    // MARK: - Initialization -
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeImages),
                                               name: Notifications.postsVCviewWillDisappear.name,
                                               object: nil)
    }
    
    
    // MARK: - super's methods -
    override func awakeFromNib() {
        super.awakeFromNib()
        profileStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped)))
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.prepareForReuse()
        photoImageView.prepareForReuse()
        photoImageView.isHidden = false
        viewCountLabel.isHidden = false
    }
}
  

// MARK: - External methods -
extension PostCell {
    
    func set(with post: Post) {
        self.post = post
        avatarImageView.downloadImage(with: post.userOwner?.photoUrl ?? post.groupOwner?.photoUrl)
        nameLabel.text    = post.userOwner?.name ?? post.groupOwner?.name
        dateLabel.text    = post.date
        postTextView.text = post.text
        layoutPostPhotos(Array(post.photos))
        viewCountLabel.setTitle(post.viewCount, for: .normal)
        viewCountLabel.isHidden   = post.viewCount == nil
        deletePostButton.isHidden = post.userOwner != User.current
        likeButton.set(likeCount: post.likeCount, liked: post.likedByCurrentUser, postId: post.id)
    }
    
    
    func reloadImages() {
        avatarImageView.reloadImage()
        photoImageView.reloadImage()
    }
}


// MARK: - Internal methods -
private extension PostCell {
    
    func layoutPostPhotos(_ photos: [Photo]) {
        guard !photos.isEmpty, let photo = photos.first else {
            photoImageView.prepareForReuse()
            photoImageView.isHidden = true
            return
        }
        photoImageView.downloadImage(with: photo.maxSizeUrl)
    }
    
    
    @objc func removeImages() {
        avatarImageView.prepareForReuse()
        photoImageView.prepareForReuse()
    }
}


//
// MARK: - PostCellDelegate's methods -
//
private extension PostCell {
    
    @objc func profileTapped() {
        guard let post = post else { return }
        delegate?.profileTapped(on: post)
    }
    
    
    @objc func photoTapped() {
        guard let post = post else { return }
        delegate?.photoTapped(on: post)
    }
    
    
    @IBAction func deletePost() {
        guard let post = post else { return }
        delegate?.deletePost(postId: post.id)
    }
}
