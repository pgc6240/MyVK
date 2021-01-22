//
//  BlurView.swift
//  MyVK
//
//  Created by pgc6240 on 14.11.2020.
//

import UIKit

final class BlurView: UIVisualEffectView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(blurEffectStyle: UIBlurEffect.Style? = nil) {
        let blurEffect = UIBlurEffect(style: blurEffectStyle ?? .systemChromeMaterial)
        super.init(effect: blurEffect)
    }
}
