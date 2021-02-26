//
//  _PushAnimator.swift
//  MyVK
//
//  Created by pgc6240 on 22.11.2020.
//

import UIKit

final class _PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        1.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source       = transitionContext.viewController(forKey: .from) else { return }
        guard let destination  = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        
        let sourceVCtranslation    = CGAffineTransform(translationX: -source.view.frame.width, y: source.view.frame.width)
        let sourceVCrotation       = CGAffineTransform(rotationAngle: .pi / 2)
        let destVCtranslation      = CGAffineTransform(translationX: source.view.frame.width, y: source.view.frame.width)
        let destVCrotation         = CGAffineTransform(rotationAngle: .pi / -2)
        
        destination.view.transform = destVCtranslation.concatenating(destVCrotation)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            
            source.view.transform       = sourceVCtranslation.concatenating(sourceVCrotation)
            destination.view.transform  = .identity
            
        } completion: { finished in
            
            source.view.transform       = .identity
            destination.view.transform  = .identity
            
            transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
        }
    }
}
