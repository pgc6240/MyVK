//
//  LikeButton.swift
//  MyVK
//
//  Created by pgc6240 on 05.11.2020.
//

import UIKit

final class LikeButton: UIControl {
    
    let likeImageView   = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 35))
    let likeCountLabel  = UILabel    (frame: CGRect(x: 40, y: 0, width: 30, height: 35))
    
    var liked           = false
    var likeCount       = 0
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layoutUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    convenience init(likeCount: Int) {
        let frame = CGRect(x: 0, y: 0, width: 60, height: 35)
        self.init(frame: frame)
        self.likeCount = likeCount
        updateUI()
    }
    
    private func layoutUI() {
        addSubviews(likeImageView, likeCountLabel)
        updateUI()
    }
    
    private func updateUI() {
        likeImageView.image = UIImage(systemName: liked ? "heart.fill" : "heart")
        likeCountLabel.text = liked ? "\(likeCount + 1)" : String(likeCount)
    }
    
    func likeTapped() {
        liked.toggle()
        updateUI()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        likeTapped()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        likeTapped()
    }
}
