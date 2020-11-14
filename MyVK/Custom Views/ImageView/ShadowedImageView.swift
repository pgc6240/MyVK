//
//  ShadowedImageView.swift
//  MyVK
//
//  Created by pgc6240 on 10.11.2020.
//

import UIKit

@IBDesignable
final class ShadowedImageView: UIView {
    
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
    
    @IBInspectable var shadowOpacity: Float = 0.75 {
        willSet { layer.shadowOpacity = newValue }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        
        layer.shadowColor   = shadowColor?.cgColor
        layer.shadowRadius  = shadowRadius
        layer.shadowOffset  = CGSize(width: shadowOffset, height: shadowOffset)
        layer.shadowOpacity = shadowOpacity
        
        layer.addSublayer(imageLayer)
        imageLayer.frame            = bounds
        imageLayer.masksToBounds    = true
    }
}
