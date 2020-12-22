//
//  UIKit+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}


extension UIViewController {
    
    func presentAlert(title: String?, message: String?, actionTitle: String? = "Хорошо") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel))
        present(alert, animated: true)
    }
    
    
    func showLoadingView() {
        let loadingViewFrame              = CGRect(x: view.bounds.midX - 30, y: view.bounds.midY, width: 60, height: 60)
        let loadingView                   = LoadingView(frame: loadingViewFrame)
        loadingView.restorationIdentifier = "loading view"
        loadingView.layer.opacity         = 0
        
        view.addSubview(loadingView)
        
        UIView.transition(with: loadingView, duration: 2, options: .curveEaseIn) {
            loadingView.layer.opacity = 1
        }
    }
    
    
    func dismissLoadingView() {
        let loadingView = view.subviews.filter { $0.restorationIdentifier == "loading view" }.first
        loadingView?.removeFromSuperview()
    }
}


extension UIColor {
    
    static var vkColor: UIColor? {
        UIColor(named: "vk-color")
    }
    
    
    static func random() -> UIColor {
        UIColor(red: CGFloat.random(in: 0...1),
                green: CGFloat.random(in: 0...1),
                blue: CGFloat.random(in: 0...1),
                alpha: 1)
    }
}
