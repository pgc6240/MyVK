//
//  PlaceholderImageView.swift
//  MyVK
//
//  Created by pgc6240 on 25.12.2020.
//

import UIKit

final class PlaceholderImageView: SelfDownloadableImageView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .secondarySystemBackground
    }
    
    
    // MARK: - Storyboard-editable propeties -
    @IBInspectable var cornerRadius: CGFloat = 0 {
        willSet { layer.cornerRadius = newValue }
    }
    
    
    // MARK: - Spring in zoom animation -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 100, initialSpringVelocity: 5, options: [.allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 100, initialSpringVelocity: 5, options: [.allowUserInteraction]) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 100, initialSpringVelocity: 5, options: [.allowUserInteraction]) {
            self.transform = .identity
        }
    }
}
