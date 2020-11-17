//
//  BlurView.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

class BlurView: UIView {
    
    var blurEffectStyle: UIBlurEffect.Style?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layoutUI()
    }
    
    init(frame: CGRect, blurEffectStyle: UIBlurEffect.Style? = nil) {
        super.init(frame: frame)
        self.blurEffectStyle = blurEffectStyle
        layoutUI()
    }
    
    private func layoutUI() {
        let blurEffect  = UIBlurEffect(style: blurEffectStyle ?? .systemUltraThinMaterial)
        let blurView    = UIVisualEffectView(effect: blurEffect)
        backgroundColor = UIColor.systemGray.withAlphaComponent(0.25)
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints                  = false
        blurView.widthAnchor.constraint(equalTo: widthAnchor).isActive      = true
        blurView.heightAnchor.constraint(equalTo: heightAnchor).isActive    = true
    }
}
