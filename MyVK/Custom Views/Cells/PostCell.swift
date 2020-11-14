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
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var likeButton: LikeButton!
    
    
    func set(with post: Post) {
        postTextView.text = post.text
        likeButton.likeCount = post.likeCount
        
        for attachment in post.attachments {
            switch attachment.type {
            case .photo:
                let photo = attachment as? Photo
                photoImageView.image = photo?.image
            }
        }
    }
}
