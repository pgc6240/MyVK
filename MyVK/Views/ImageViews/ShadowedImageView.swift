//
//  ShadowedImageView.swift
//  MyVK
//
//  Created by pgc6240 on 10.11.2020.
//

import UIKit

final class ShadowedImageView: UIView, URLDownloadableImage {
    
    var downloadURLString: String?
    weak var downloadImageOperation: DownloadImageOperation?
    
    
    var imageLayer = CALayer()

    @IBInspectable var image: UIImage? {
        didSet { imageLayer.contents = image?.cgImage }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        willSet { imageLayer.cornerRadius = newValue }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        willSet { layer.shadowColor = newValue?.cgColor }
    }

    @IBInspectable var shadowRadius: CGFloat = 4 {
        willSet { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var shadowOffset: CGFloat = 0 {
        willSet { layer.shadowOffset = CGSize(width: newValue, height: newValue) }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.5 {
        willSet { layer.shadowOpacity = newValue }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundColor = .clear
        
        layer.masksToBounds = false
        layer.shadowColor   = shadowColor?.cgColor
        layer.shadowRadius  = shadowRadius
        layer.shadowOffset  = CGSize(width: shadowOffset, height: shadowOffset)
        layer.shadowOpacity = shadowOpacity
        
        layer.addSublayer(imageLayer)
        imageLayer.frame         = bounds
        imageLayer.masksToBounds = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(springInImage)))
    }
    
    
    @objc func springInImage() {
        let springInAnimation           = CASpringAnimation(keyPath: "transform.scale")
        springInAnimation.toValue       = 0.75
        springInAnimation.stiffness     = 200
        springInAnimation.mass          = 0.5
        springInAnimation.duration      = 0.15
        springInAnimation.autoreverses  = true
        
        layer.add(springInAnimation, forKey: nil)
    }
}
