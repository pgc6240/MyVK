//
//  _NavigationController.swift
//  MyVK
//
//  Created by pgc6240 on 22.11.2020.
//

import UIKit

final class _NavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    
    // MARK: - UINavigationControllerDelegate -
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            return toVC is PhotosVC ? _PushAnimator() : nil
        case .pop:
            return fromVC is PhotosVC ? _PopAnimator() : nil
        default:
            return nil
        }
    }
}
