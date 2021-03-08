//
//  UIKit+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 03.11.2020.
//

import UIKit

// MARK: - Alerts -
extension UIViewController {
    
    func makeAlert(title: String?, message: String? = nil, cancelTitle: String = "Хорошо") -> UIAlertController {
        let alert  = UIAlertController(title: title?.localized, message: message?.localized, preferredStyle: .alert)
        let cancel = UIAlertAction(title: cancelTitle.localized, style: .cancel)
        alert.view.tintColor = .vkColor
        alert.addAction(cancel)
        return alert
    }
    
    
    func presentAlert(title: String?, message: String? = nil, cancelTitle: String = "Хорошо") {
        let alert = makeAlert(title: title, message: message, cancelTitle: cancelTitle)
        present(alert, animated: true)
    }
    
    
    func presentFailureAlert() {
        presentAlert(title: "Что-то пошло не так...", message: "Мы работаем над этим.")
    }
    
    
    func presentNetworkUnavailableAlert() {
        let alert        = makeAlert(title: "Отсутствует соединение с интернетом.", cancelTitle: "Закрыть")
        let goToSettings = UIAlertAction(title: "Настройки".localized, style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        }
        alert.addAction(goToSettings)
        present(alert, animated: true)
    }
    
    
    func presentActionSheet(title: String?, message: String? = nil, actions: [UIAlertAction] = []) {
        let actionSheet = UIAlertController(title: title?.localized, message: message?.localized, preferredStyle: .actionSheet)
        actions.forEach { actionSheet.addAction($0) }
        actionSheet.view.tintColor = .vkColor
        present(actionSheet, animated: true)
    }
}
    
    
// MARK: - Loading state -
extension UIViewController {
    
    var isLoading: Bool           { loadingView != nil }
    var loadingView: LoadingView? { viewToAdd.viewWithTag(loadingViewTag) as? LoadingView }
    var loadingViewTag: Int       { 1_000 }
    var viewToAdd: UIView         { parent?.view ?? view }
    
    
    func showLoadingView() {
        guard !isLoading else { return }
        let loadingView = LoadingView(width: 60, in: viewToAdd.bounds, color: .white, backgroundColor: .vkColor)
        loadingView.tag = loadingViewTag
        viewToAdd.addSubview(loadingView)
        
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
}


extension UIViewController {
    
    var previousViewController: UIViewController? {
        guard let navigationController = navigationController,
              let indexOfSelf          = navigationController.viewControllers.firstIndex(of: self),
                  indexOfSelf >= 1 else { return nil }
        return navigationController.viewControllers[indexOfSelf - 1]
    }
}


extension UIColor {
    static let vkColor = UIColor(named: "AccentColor")
}


extension UITableViewCell {
    static var reuseId: String { String(describing: self) }
    static var nib:     UINib  { UINib(nibName: reuseId, bundle: nil) }
}


extension UICollectionViewCell {
    static var reuseId: String { String(describing: self) }
}


extension UITableViewHeaderFooterView {
    static var reuseId: String { String(describing: self) }
}


extension UIImage {
    
    convenience init?(data: Data?) {
        guard let data = data else { return nil }
        self.init(data: data)
    }
}


extension UIStoryboard {
    static var main: UIStoryboard { UIStoryboard(name: "Main", bundle: nil) }
}


extension UITableView: Identifiable {
    
    func reloadData(animated: Bool) {
        if animated {
            UIView.transition(with: self, duration: 0.35, options: [.transitionCrossDissolve, .allowUserInteraction]) {
                [weak self] in
                self?.reloadData()
            }
        } else {
            reloadData()
        }
    }
    
    
    func reloadVisibleRows(with animation: UITableView.RowAnimation = .none) {
        guard let indexPaths = indexPathsForVisibleRows else { return }
        reloadRows(at: indexPaths, with: animation)
    }
}
