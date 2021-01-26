//
//  UIKit+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit
import Alamofire

extension UIViewController {
    

    func presentAlert(title: String?, message: String? = nil, actionTitle: String = "Хорошо") {
        let alert = UIAlertController(title: title?.localized, message: message?.localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle.localized, style: .cancel))
        present(alert, animated: true)
    }
    
    
    // MARK: - Loading state -
    var loadingViewTag: Int { 1000 }
    var loadingView: LoadingView? { view.viewWithTag(loadingViewTag) as? LoadingView }
    var isLoading: Bool { view.viewWithTag(loadingViewTag) != nil }
    
    
    func showLoadingView() {
        guard !isLoading else { return }
        
        let loadingView = LoadingView(width: 60, in: view.bounds, color: .white, backgroundColor: .vkColor)
        loadingView.tag = loadingViewTag
        view.addSubview(loadingView)
        
        loadingView.startLoading()
        loadingView.layer.opacity = 0
        UIView.transition(with: loadingView, duration: 2, options: .transitionCrossDissolve) {
            loadingView.layer.opacity = 1
        }
    }
    
    
    func dismissLoadingView() {
        loadingView?.stopLoading()
        loadingView?.removeFromSuperview()
    }
    
    
    // MARK: - Network reachability status -
    func presentNetworkUnavailableAlert() {
        let alertTitle = "Отсутствует соединение с интернетом.".localized
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Закрыть".localized, style: .cancel)
        let goToSettings = UIAlertAction(title: "Настройки".localized, style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        }
        alert.addAction(cancel)
        alert.addAction(goToSettings)
        present(alert, animated: true)
    }
}


extension UIColor {
    static var vkColor: UIColor? { UIColor(named: "AccentColor") }
}


extension UITableViewCell {
    static var reuseId: String { String(describing: self) }
}


extension UICollectionViewCell {
    static var reuseId: String { String(describing: self) }
}
