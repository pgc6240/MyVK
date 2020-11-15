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
    @IBOutlet weak var photosStackView: UIStackView!
    @IBOutlet var photosImageViews: [UIImageView]!
    
    var photos: [Photo] = []
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photos = []
        photosImageViews.forEach { $0.image = nil }
    }
    
    
    func set(with post: Post) {
        //postTextView.text = post.text
        likeButton.likeCount = post.likeCount
        viewCount.setTitle("\(post.viewCount)", for: .normal)
        
        for (i, attachment) in post.attachments.enumerated() {
            switch attachment.type {
            case .photo:
                if let photo = attachment as? Photo {
                    photos.append(photo)
                    photosImageViews[i].image = photo.image
                }
            }
        }
        
        photosStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photosTapped)))
    }
    
    @objc func photosTapped() {
        let photosVC = PhotosVC(photos: photos, maxPhotosPerSection: Int.random(in: 1...photos.count))
        let tabBarController = UIApplication.shared.windows.first?.rootViewController as? TabBarController
        let navigationController = tabBarController?.selectedViewController as? UINavigationController
        navigationController?.pushViewController(photosVC, animated: true)
    }
}
