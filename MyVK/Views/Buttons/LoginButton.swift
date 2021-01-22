//
//  MyButton.swift
//  MyVK
//
//  Created by pgc6240 on 17.11.2020.
//

import UIKit

final class LoginButton: UIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .allowUserInteraction)
        {
            self.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let isTouchInside = bounds.contains(touches.first?.location(in: self) ?? .zero)
        
        UIView.animate(withDuration: 0.9,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .allowUserInteraction)
        {
            self.transform = isTouchInside ? CGAffineTransform(scaleX: 1.12, y: 1.12) : .identity
        }
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard isTouchInside else { return }
            self.sendActions(for: .touchUpInside)
        }
    }
}
