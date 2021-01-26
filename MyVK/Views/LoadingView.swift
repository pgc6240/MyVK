//
//  LoadingView.swift
//  MyVK
//
//  Created by pgc6240 on 17.11.2020.
//

import UIKit

final class LoadingView: UIView {
    
    // MARK: - External properties -
    var color: UIColor?
    
    
    // MARK: - Internal properties -
    private let circleLayer  = CAShapeLayer()
    private let animationKey = "loadingViewAnimation"
    
    
    // MARK: - Initialization -
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layoutUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(width: CGFloat = 60,
                     in bounds: CGRect,
                     color: UIColor? = UIColor(named: "AccentColor"),
                     backgroundColor: UIColor? = .black)
    {
        let frame = CGRect(x: bounds.midX - width / 2, y: bounds.midY - width / 2, width: width, height: width)
        self.init(frame: frame)
        self.color = color
        self.layoutUI()
        self.backgroundColor = backgroundColor?.withAlphaComponent(0.7)
    }
    
    
    // MARK: - UI -
    private func layoutUI() {
        let width = bounds.width
        let circlePath = UIBezierPath(roundedRect: bounds.insetBy(dx: width / 5, dy: width / 5), cornerRadius: width / 2)
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = color?.cgColor
        circleLayer.lineWidth = width / 10
        layer.addSublayer(circleLayer)
        layer.cornerRadius = 8
    }
    
    
    // MARK: - Loading animation -
    func startLoading() {
        let strokeStartAnimation       = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue   = 1
        
        let strokeEndAnimation         = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        strokeEndAnimation.fromValue   = 0
        strokeEndAnimation.toValue     = 2
        
        let animationGroup             = CAAnimationGroup()
        animationGroup.duration        = 1.5
        animationGroup.animations      = [strokeStartAnimation, strokeEndAnimation]
        animationGroup.repeatCount     = .infinity
        
        circleLayer.add(animationGroup, forKey: animationKey)
    }
    
    
    func stopLoading() {
        circleLayer.removeAnimation(forKey: animationKey)
    }
}
