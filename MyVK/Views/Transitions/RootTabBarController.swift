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
    @UserDefault(key: "selectedTab", defaultValue: 0)
    var selectedTab
    
    
    override var selectedViewController: UIViewController? {
        willSet {
            guard let selectedVC = newValue,
                  let selectedVCIndex = viewControllers?.firstIndex(of: selectedVC) else { return }
            selectedTab = selectedVCIndex
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectedIndex = selectedTab
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
