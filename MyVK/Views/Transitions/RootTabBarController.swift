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
        guard let _ = User.current else {
            SessionManager.logout()
            return
        }
        selectedIndex = PersistenceManager.selectedTab
        startObservingNetworkStatus()
    }
    
    
    // MARK: - Network reachability status -
    let networkReachabilityManager = NetworkReachabilityManager(host: "yandex.ru")
    
    func startObservingNetworkStatus() {
        networkReachabilityManager?.startListening { [weak self] status in
            if status == .notReachable {
                self?.presentNetworkUnavailableAlert()
            }
        }
    }
}
