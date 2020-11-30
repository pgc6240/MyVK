//
//  LoadingView.swift
//  MyVK
//
//  Created by pgc6240 on 17.11.2020.
//

import UIKit

final class LoadingView: UIView {
    
    let circleLayer = CAShapeLayer()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor     = UIColor.vkColor?.withAlphaComponent(0.75)
        layer.cornerRadius  = 8
        
        let circlePath          = UIBezierPath(roundedRect: bounds.insetBy(dx: 12, dy: 12), cornerRadius: bounds.width / 2)
        circleLayer.path        = circlePath.cgPath
        circleLayer.fillColor   = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.lineWidth   = 5
        
        layer.addSublayer(circleLayer)
        
        startAnimating()
    }
    
    
    func startAnimating() {
        let strokeStartAnimation        = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        strokeStartAnimation.fromValue  = 0
        strokeStartAnimation.toValue    = 1
        
        let strokeEndAnimation          = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        strokeEndAnimation.fromValue    = 0
        strokeEndAnimation.toValue      = 2
        
        let animationGroup              = CAAnimationGroup()
        animationGroup.duration         = 2
        animationGroup.animations       = [strokeStartAnimation, strokeEndAnimation]
        animationGroup.repeatCount      = .infinity
        
        circleLayer.add(animationGroup, forKey: nil)
    }
}
