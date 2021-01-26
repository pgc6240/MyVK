//
//  RootTabBarController.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import UIKit
import Alamofire

final class RootTabBarController: UITabBarController {
    
    // MARK: - Selected tab persistence -
    override var selectedViewController: UIViewController? {
        willSet {
            guard let selectedVC = newValue else { return }
            guard let selectedVCIndex = viewControllers?.firstIndex(of: selectedVC) else { return }
            PersistenceManager.selectedTab = selectedVCIndex
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectedIndex = PersistenceManager.selectedTab
        networkReachabilityManager?.startListening(onUpdatePerforming: networkReachabilityStatusChanged)
    }
    
    
    // MARK: - Network reachability -
    let networkReachabilityManager = NetworkReachabilityManager(host: "yandex.ru")
    
    func networkReachabilityStatusChanged(_ status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        if status == .notReachable {
            let goToSettings = UIAlertAction(title: "Настройки", style: .default) { _ in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsURL)
            }
            presentAlert(title: "Отсутствует соединение с интернетом.", action: goToSettings, cancelTitle: "Закрыть")
        }
    }
}
