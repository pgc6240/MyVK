//
//  LikeButton.swift
//  MyVK
//
//  Created by pgc6240 on 05.11.2020.
//

import UIKit

final class LikeButton: UIButton {
    
    var liked     = false { didSet { updateUI() }}
    var likeCount = 0     { didSet { updateUI() }}
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintColor = liked ? .vkColor : .secondaryLabel
        updateUI()
    }
    
    private func updateUI() {
        UIView.transition(with: self, duration: 0.5, options: [.allowUserInteraction, .transitionFlipFromBottom]) {
            [liked, likeCount] in
            
            self.setImage(UIImage(systemName: liked ? "heart.fill" : "heart"), for: .normal)
            self.setTitle(liked ? "\(likeCount + 1)" : "\(likeCount)", for: .normal)
            self.setTitleColor(self.tintColor, for: .normal)
        }
    }
    
    @objc func likeTapped() {
        liked.toggle()
    }
}
