//
//  GradientView.swift
//  MyVK
//
//  Created by pgc6240 on 10.11.2020.
//

import UIKit

@IBDesignable
final class GradientView: UIView {

    var gradientLayer: CAGradientLayer      { layer as! CAGradientLayer }
    override class var layerClass: AnyClass { CAGradientLayer.self }
    
    @IBInspectable var startColor: UIColor     = .white { didSet  { updateColors() }}
    @IBInspectable var endColor: UIColor       = .black { didSet  { updateColors() }}
    @IBInspectable var startLocation: CGFloat  = 0      { didSet  { updateLocations() }}
    @IBInspectable var endLocation: CGFloat    = 1      { didSet  { updateLocations() }}
    @IBInspectable var startPoint: CGPoint     = .zero  { willSet { gradientLayer.startPoint = newValue }}
    @IBInspectable var endPoint: CGPoint       = .zero  { willSet { gradientLayer.startPoint = newValue }}
    
    
    private func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    private func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
}
