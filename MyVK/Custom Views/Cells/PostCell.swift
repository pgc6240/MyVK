//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class PostCell: UITableViewCell {

    static let reuseId = String(describing: self)
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCount: UIButton!
    @IBOutlet var photosImageViews: [UIImageView]!
    
    
    func set(with post: Post) {
        //postTextView.text = post.text
        likeButton.likeCount = post.likeCount
        viewCount.setTitle("\(post.viewCount)", for: .normal)
        
        for (i, attachment) in post.attachments.enumerated() {
            switch attachment.type {
            case .photo:
                let photo = attachment as? Photo
                photosImageViews[i].image = photo?.image
            }
        }
    }
}
