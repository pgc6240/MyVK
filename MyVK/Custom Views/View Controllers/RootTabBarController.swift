//
//  RootTabBarController.swift
//  MyVK
//
//  Created by pgc6240 on 07.11.2020.
//

import UIKit

final class RootTabBarController: UITabBarController {

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
        overrideUserInterfaceStyle = .dark
    }
}
