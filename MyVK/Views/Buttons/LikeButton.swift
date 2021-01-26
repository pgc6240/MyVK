//
//  LikeButton.swift
//  MyVK
//
//  Created by pgc6240 on 05.11.2020.
//

import UIKit

final class LikeButton: UIButton {
    
    var likeCount = 0
    var liked     = false
    var postId    = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(like), for: .touchUpInside)
    }
    
    func set(likeCount: Int, liked: Bool, postId: Int, animated: Bool = false) {
        self.likeCount = likeCount
        self.liked     = liked
        self.postId    = postId
        updateUI(animated: animated)
    }
    
    private func updateUI(animated: Bool = false) {
        UIView.transition(with: self,
                          duration: animated ? 0.5 : 0,
                          options: [.allowUserInteraction, .transitionFlipFromBottom])
        { [likeCount, liked] in
            
            self.setImage(UIImage(systemName: liked ? "heart.fill" : "heart"), for: .normal)
            self.setTitle(String(likeCount), for: .normal)
            self.tintColor = liked ? .systemRed : .secondaryLabel
        }
    }
    
    @objc func like() {
        NetworkManager.shared.like(like: liked ? false : true, type: "post", itemId: postId) { [weak self, liked, postId] in
            guard let likeCount = $0 else { return }
            self?.set(likeCount: likeCount, liked: !liked, postId: postId, animated: true)
        }
    }
}
