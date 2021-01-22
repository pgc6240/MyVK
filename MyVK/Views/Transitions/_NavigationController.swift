//
//  _NavigationController.swift
//  MyVK
//
//  Created by pgc6240 on 22.11.2020.
//

import UIKit

final class _NavigationController: UINavigationController, UINavigationControllerDelegate {

    weak var interactiveTransition: _InteractiveTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            return _PushAnimator()
        case .pop:
            return _PopAnimator()
        default:
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransition?.hasBegan ?? false ? interactiveTransition : nil
    }
}
