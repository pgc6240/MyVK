//
//  PostCell.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class PostCell: UITableViewCell {
    static let reuseId = String(describing: PostCell.self)
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var viewCount: UIButton!
    @IBOutlet weak var photosStackView: UIStackView!
    @IBOutlet var photosImageViews: [UIImageView]!
    
    var photos: [Photo] = []
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photosImageViews.forEach { $0.image = nil }
        photos = []
    }
    
    
    func set(with post: Post) {
        likeButton.likeCount = post.likeCount
        viewCount.setTitle("\(post.viewCount)", for: .normal)
        
        for (index, photo) in post.photos.enumerated() {
            //photosImageViews[index].image = photo.image
            photos.append(photo)
        }
        
        photosStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photosTapped)))
    }
    
    
    @objc func photosTapped() {
        let photosVC             = PhotosVC(photos)
        let tabBarController     = UIApplication.shared.windows.first?.rootViewController as? _TabBarController
        let navigationController = tabBarController?.selectedViewController as? _NavigationController
        
        navigationController?.pushViewController(photosVC, animated: true)
    }
}
