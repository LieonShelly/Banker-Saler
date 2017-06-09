//
//  DismissingAnimator.swift
//  FPTrade
//
//  Created by Kuma on 9/8/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//

import UIKit
import pop

class MoveFromRightDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var completionBlock: ((Void) -> Void)?
    
    init(block: ((Void) -> Void)? = nil) {
        super.init()
        completionBlock = block
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
       guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.tintAdjustmentMode = UIViewTintAdjustmentMode.normal
        toView.isUserInteractionEnabled = true
        
       guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        
        guard let offscreenAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionX)  else { return }
        offscreenAnimation.toValue = screenWidth * 2
        offscreenAnimation.completionBlock = {(anim, finished) -> Void in
            transitionContext.completeTransition(true)
            
            if let block = self.completionBlock {
                block()
            }
        }
        
        fromView.layer.pop_add(offscreenAnimation, forKey: "offscreenAnimation")
    }
    
}

class CellSidebarDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
       guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.tintAdjustmentMode = UIViewTintAdjustmentMode.normal
        toView.isUserInteractionEnabled = true
        
        guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        
       guard  let offscreenAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionX) else { return }
        offscreenAnimation.toValue = screenWidth + 150
        offscreenAnimation.completionBlock = {(anim, finished) -> Void in transitionContext.completeTransition(true)}
        
        fromView.layer.pop_add(offscreenAnimation, forKey: "offscreenAnimation")
    }
    
}

class NavPopoverDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
       guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.tintAdjustmentMode = UIViewTintAdjustmentMode.normal
        toView.isUserInteractionEnabled = true
        
       guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        
      guard  let opacityAnimation = POPBasicAnimation(propertyNamed:kPOPLayerOpacity) else { return }
        opacityAnimation.toValue = 0.0
        opacityAnimation.completionBlock = {(anim, finished) -> Void in transitionContext.completeTransition(true)}

        fromView.layer.pop_add(opacityAnimation, forKey: "opacityAnimation")
    }
    
}

class PublishNewTaskDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.tintAdjustmentMode = UIViewTintAdjustmentMode.normal
        toView.isUserInteractionEnabled = true
        
       guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        
       guard let opacityAnimation = POPBasicAnimation(propertyNamed:kPOPLayerOpacity) else { return }
        opacityAnimation.toValue = 0.0
        opacityAnimation.completionBlock = { (anim, finished) -> Void in transitionContext.completeTransition(true)}
        
        fromView.layer.pop_add(opacityAnimation, forKey: "opacityAnimation")
    }
    
}

class ShopProductMoveDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
       guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.tintAdjustmentMode = UIViewTintAdjustmentMode.normal
        toView.isUserInteractionEnabled = true
        
        var dimmingView: UIView?

        for subview in transitionContext.containerView.subviews where subview.layer.opacity < 1.0 {
            dimmingView = (subview )
            break
        }

      guard  let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        
        let offscreenAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        offscreenAnimation?.toValue = screenHeight + 354
        
        fromView.layer.pop_add(offscreenAnimation, forKey: "offscreenAnimation")
        
        let opacityAnimation = POPBasicAnimation(propertyNamed:kPOPLayerOpacity)
        opacityAnimation?.toValue = 0.0
        
        fromView.layer.pop_add(opacityAnimation, forKey: "opacityAnimation")
        if let dimmingView = dimmingView {
            dimmingView.layer.pop_add(opacityAnimation, forKey:"opacityAnimation")
        }
        
        opacityAnimation?.completionBlock = {(anim, finished) -> Void in transitionContext.completeTransition(true)}

    }

}
