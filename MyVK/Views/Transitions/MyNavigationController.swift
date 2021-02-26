//
//  MyNavigationController.swift
//  MyVK
//
//  Created by pgc6240 on 22.11.2020.
//

import UIKit

final class MyNavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    
    // MARK: - UINavigationControllerDelegate -
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            return toVC is PhotosVC ? MyPushAnimator() : nil
        case .pop:
            return fromVC is PhotosVC ? MyPopAnimator() : nil
        default:
            return nil
        }
    }
}
