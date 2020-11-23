//
//  _PushAnimator.swift
//  MyVK
//
//  Created by pgc6240 on 22.11.2020.
//

import UIKit

final class _PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.6
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source      = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        destination.view.frame     = source.view.frame
        destination.view.transform = CGAffineTransform(translationX: source.view.frame.width, y: 0)
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                delay: 0,
                                options: .calculationModePaced)
        {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.75) {
                let tranlationX       = CGAffineTransform(translationX: -200, y: 0)
                let scale             = CGAffineTransform(scaleX: 0.8, y: 0.8)
                source.view.transform = tranlationX.concatenating(scale)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4) {
                let translationX           = CGAffineTransform(translationX: source.view.frame.width / 2, y: 0)
                let scale                  = CGAffineTransform(scaleX: 1.2, y: 1.2)
                destination.view.transform = translationX.concatenating(scale)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                destination.view.transform = .identity
            }
            
        } completion: { finished in
            if finished && !transitionContext.transitionWasCancelled {
                source.view.transform = .identity
            }
            transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
        }
    }
}
