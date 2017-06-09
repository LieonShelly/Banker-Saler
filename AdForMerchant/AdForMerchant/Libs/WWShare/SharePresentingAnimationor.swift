//
//  PresentingAnimationor.swift
//  BankManager
//
//  Created by Scott on 16/2/26.
//  Copyright © 2016年 choice. All rights reserved.
//

import UIKit

///产品分享转场 - dismissed
open class SharePresentingAnimationor: NSObject, UIViewControllerAnimatedTransitioning {
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard  let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        fromView.tintAdjustmentMode = UIViewTintAdjustmentMode.dimmed
        fromView.isUserInteractionEnabled = false
        
      guard  let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        transitionContext.containerView.addSubview(toView)
        
        transitionContext.completeTransition(true)
    }
    
}
