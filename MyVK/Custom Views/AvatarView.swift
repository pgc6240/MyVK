//
//  AvatarView.swift
//  MyVK
//
//  Created by pgc6240 on 05.11.2020.
//

import UIKit

@IBDesignable
final class AvatarView: UIView {
    
    @IBInspectable var shadowColor: UIColor = .black {
        willSet { layer.shadowColor = newValue.cgColor }
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
}
