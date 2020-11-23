//
//  _NavigationController.swift
//  MyVK
//
//  Created by pgc6240 on 22.11.2020.
//

import UIKit

final class _NavigationController: UINavigationController, UINavigationControllerDelegate {

    var popAnimator: UIViewControllerAnimatedTransitioning?
    var interactiveTransition: UIViewControllerInteractiveTransitioning?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            return _PushAnimator()
        case .pop:
            popAnimator = _PopAnimator()
            return popAnimator
        default:
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        animationController === popAnimator ? interactiveTransition : nil
    }
}
