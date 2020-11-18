//
//  UIKit+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

extension UIColor {
    
    static func random() -> UIColor {
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
    }
}


extension UIViewController {
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Хорошо", style: .cancel))
        present(alert, animated: true)
    }
    
    
    func showLoadingView(duration: TimeInterval) {
        
        let loadingView             = LoadingView(frame: .zero, blurEffectStyle: .dark)
        loadingView.frame.origin.x  = view.frame.midX - loadingView.intrinsicContentSize.width / 2
        loadingView.frame.origin.y  = view.frame.midY - loadingView.intrinsicContentSize.height / 2
        
        view.addSubview(loadingView)
        
        UIView.transition(with: loadingView, duration: duration, options: .curveEaseIn) {
            loadingView.layer.opacity = 0
            
        } completion: { _ in
            loadingView.removeFromSuperview()
        }
    }
}


extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
