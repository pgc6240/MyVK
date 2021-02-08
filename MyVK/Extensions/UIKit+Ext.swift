//
//  UIKit+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit
import Alamofire

extension UIViewController {
    
    // MARK: - Alerts -
    func makeAlert(title: String?, message: String? = nil, cancelTitle: String = "Хорошо") -> UIAlertController {
        let alert = UIAlertController(title: title?.localized, message: message?.localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle.localized, style: .cancel))
        alert.view.tintColor = .vkColor
        return alert
    }

    func presentAlert(title: String?, message: String? = nil, cancelTitle: String = "Хорошо") {
        let alert = makeAlert(title: title, message: message, cancelTitle: cancelTitle)
        present(alert, animated: true)
    }
    
    func presentFailureAlert() {
        presentAlert(title: "Что-то пошло не так...", message: "Мы работаем над этим.")
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
        let alert = makeAlert(title: "Отсутствует соединение с интернетом.", cancelTitle: "Закрыть")
        let goToSettings = UIAlertAction(title: "Настройки".localized, style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        }
        alert.addAction(goToSettings)
        present(alert, animated: true)
    }
}


extension UIColor {
    static var vkColor: UIColor? { UIColor(named: "AccentColor") }
}


extension UITableViewCell {
    static var reuseId: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: reuseId, bundle: nil) }
}


extension UICollectionViewCell {
    static var reuseId: String { String(describing: self) }
}
