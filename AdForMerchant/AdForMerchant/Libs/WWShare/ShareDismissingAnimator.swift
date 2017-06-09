//
//  DismissingAnimator.swift
//  BankManager
//
//  Created by Scott on 16/2/26.
//  Copyright © 2016年 choice. All rights reserved.
//

import UIKit

///产品分享转场 present
open class ShareDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view
        toView?.tintAdjustmentMode = .normal
        toView?.isUserInteractionEnabled = true
        guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        fromView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        UIView.animate(withDuration: 0.2, animations: { 
            fromView.alpha = 0.02
            }, completion: { (complete) in
                transitionContext.completeTransition(true)
        }) 
        
    }
    
}
