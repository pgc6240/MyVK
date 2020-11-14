//
//  LikeButton.swift
//  MyVK
//
//  Created by pgc6240 on 05.11.2020.
//

import UIKit

final class LikeButton: UIButton {
    
    var liked       = false { didSet { layoutSubviews() }}
    var likeCount   = 0     { didSet { layoutSubviews() }}
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintColor = liked ? Colors.vkColor : .secondaryLabel
        setImage(UIImage(systemName: liked ? "heart.fill" : "heart"), for: .normal)
        setTitle(liked ? "\(likeCount + 1)" : "\(likeCount)", for: .normal)
    }
    
    @objc func likeTapped() {
        liked.toggle()
    }
}
