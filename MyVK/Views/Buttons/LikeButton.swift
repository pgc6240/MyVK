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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(like), for: .touchUpInside)
    }
    
    func set(likeCount: Int, liked: Bool) {
        self.likeCount = likeCount
        self.liked     = liked
        updateUI()
    }
    
    private func updateUI(animated: Bool = false) {
        UIView.transition(with: self,
                          duration: animated ? 0.5 : 0,
                          options: [.allowUserInteraction, .transitionFlipFromBottom])
        { [likeCount, liked] in
            
            self.setImage(UIImage(systemName: liked ? "heart.fill" : "heart"), for: .normal)
            self.setTitle(String(likeCount), for: .normal)
            self.setTitleColor(liked ? .vkColor : .secondaryLabel, for: .normal)
            self.tintColor = liked ? .vkColor : .secondaryLabel
        }
    }
    
    @objc func like() {
        liked.toggle()
        updateUI(animated: true)
    }
}
