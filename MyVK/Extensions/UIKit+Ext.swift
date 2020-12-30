//
//  UIKit+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

extension UIViewController {
    
    var isLoading: Bool { view.viewWithTag(loadingViewTag) != nil }
    var loadingViewTag: Int { 1000 }
    
    
    func presentAlert(title: String? = nil, message: String?, actionTitle: String = "Хорошо") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel))
        present(alert, animated: true)
    }
    
    
    func showLoadingView() {
        guard !isLoading else { return }
        
        let width: CGFloat = 60
        let frame = CGRect(x: view.bounds.midX - width / 2, y: view.bounds.midY, width: width, height: width)
        let loadingView = LoadingView(frame: frame)
        loadingView.tag = loadingViewTag
        loadingView.layer.opacity = 0
        view.addSubview(loadingView)
        
        UIView.transition(with: loadingView, duration: 2, options: .transitionCrossDissolve) {
            loadingView.layer.opacity = 1
        }
    }
    
    
    func dismissLoadingView() {
        let loadingView = view.viewWithTag(loadingViewTag)
        loadingView?.removeFromSuperview()
    }
}


extension UIColor {
    
    static var vkColor: UIColor? {
        UIColor(named: "AccentColor")
    }
}
