//
//  LoadingView.swift
//  MyVK
//
//  Created by pgc6240 on 17.11.2020.
//

import UIKit

final class LoadingView: BlurView {

    var pointDiameter: CGFloat  = 15
    var spacing: CGFloat        = 5
    
    lazy var point: (CGFloat, CGFloat, Float) -> UIView = { [bounds] originX, diameter, opacity in
        let point = UIView(frame: CGRect(x: originX, y: bounds.midY - diameter / 2, width: diameter, height: diameter))
        point.backgroundColor = .white
        point.layer.cornerRadius = diameter / 2
        point.layer.opacity = opacity
        return point
    }
    
    var point1: UIView!
    var point2: UIView!
    var point3: UIView!
    
    override var intrinsicContentSize: CGSize {
        let width = spacing * 4 + pointDiameter * 3
        return CGSize(width: width, height: width)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        frame.size = intrinsicContentSize
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        point1 = point(spacing, pointDiameter, 1)
        point2 = point(point1.frame.maxX + spacing, pointDiameter, 0.4)
        point3 = point(point2.frame.maxX + spacing, pointDiameter, 0.1)
        
        addSubviews(point1, point2, point3)
        startAnimating()
    }
    
    
    func startAnimating() {
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.repeat, .autoreverse]) {
            [weak point1, weak point2, weak point3] in
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                point1?.layer.opacity = 0.4
                point2?.layer.opacity = 1
                point3?.layer.opacity = 0.4
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1) {
                point1?.layer.opacity = 0.1
                point2?.layer.opacity = 0.4
                point3?.layer.opacity = 1
            }
        }
    }
}
