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
    @IBOutlet weak var profileStackView:    UIStackView!
    @IBOutlet weak var avatarImageView:     PlaceholderImageView!
    @IBOutlet weak var nameLabel:           PlaceholderLabel!
    @IBOutlet weak var dateLabel:           SecondaryPlaceholderLabel!
    @IBOutlet weak var deletePostButton:    EnlargedButton!
    @IBOutlet weak var postTextView:        PostTextView!
    @IBOutlet weak var showMoreTextButton:  UIButton!
    @IBOutlet weak var photoImageView:      PlaceholderImageView!
    @IBOutlet weak var photosCountLabel:    UILabel!
    @IBOutlet weak var attachementsLabel:   UILabel!
    @IBOutlet weak var likeButton:          LikeButton!
    @IBOutlet weak var viewCountLabel:      UIButton!

    
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
        photoImageView.isHidden     = false
        viewCountLabel.isHidden     = false
        postTextView.isHidden       = false
        showMoreTextButton.isHidden = false
        attachementsLabel.isHidden  = false
        photosCountLabel.isHidden   = false
        showMoreTextButton.setTitle("Показать полностью...".localized, for: .normal)
    }
}
  

// MARK: - External methods -
extension PostCell {
    
    func set(with post: Post, textCropped: inout Bool?) {
        self.post = post
        nameLabel.text = post.userOwner?.name ?? post.groupOwner?.name
        dateLabel.text = post.date
        postTextView.text = post.text
        attachementsLabel.text = post.attachmentsString
        cropText(&textCropped)
        hideEmptyViews(on: post)
        layoutPostPhotos(Array(post.photos))
        viewCountLabel.setTitle(post.viewCount, for: .normal)
        likeButton.set(likeCount: post.likeCount, liked: post.likedByCurrentUser, postId: post.id)
        avatarImageView.downloadImage(with: post.userOwner?.photoUrl ?? post.groupOwner?.photoUrl)
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
            photoImageView.isHidden   = true
            photosCountLabel.isHidden = true
            return
        }
        photoImageView.downloadImage(with: photo.maxSizeUrl)
        photosCountLabel.text = photos.count == 1 ? nil : "+\(photos.count - 1)"
    }
    
    
    @objc func removeImages() {
        avatarImageView.prepareForReuse()
        photoImageView.prepareForReuse()
    }
    
    
    func cropText(_ textCropped: inout Bool?) {
        let postTextHeight = postTextView.text.size(in: bounds.width).height
        if let textCropped = textCropped {
            postTextView.textContainer.maximumNumberOfLines = textCropped ? 9 : 0
            postTextView.invalidateIntrinsicContentSize()
            showMoreTextButton.isHidden = !textCropped && postTextHeight < 200
            showMoreTextButton.setTitle((textCropped ? "Показать полностью..." : "Скрыть").localized, for: .normal)
        } else {
            textCropped = postTextHeight > 200
            postTextView.textContainer.maximumNumberOfLines = textCropped! ? 9 : 0
            postTextView.invalidateIntrinsicContentSize()
            showMoreTextButton.isHidden = !textCropped!
        }
    }
    
    
    func hideEmptyViews(on post: Post) {
        postTextView.isHidden      = postTextView.text.isEmpty
        viewCountLabel.isHidden    = post.viewCount == nil
        deletePostButton.isHidden  = post.userOwner != User.current
        attachementsLabel.isHidden = post.attachmentsString == nil
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
    
    
    @IBAction func showMoreText() {
        delegate?.showMoreText(at: tag)
    }
    
    
    @IBAction func deletePost() {
        guard let post = post else { return }
        delegate?.deletePost(postId: post.id)
    }
}
