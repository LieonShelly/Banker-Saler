//
//  PresentingAnimator.swift
//  FPTrade
//
//  Created by Kuma on 9/8/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//

import UIKit
import pop

class MoveFromRightPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var completionBlock: ((Void) -> Void)?
    
    init(block: ((Void) -> Void)? = nil) {
        super.init()
        completionBlock = block
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        fromView.tintAdjustmentMode = UIViewTintAdjustmentMode.dimmed
        fromView.isUserInteractionEnabled = false
    
       guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
        transitionContext.containerView.addSubview(toView)
        
      guard  let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionX) else { return }
        positionAnimation.toValue = screenWidth / 2
        positionAnimation.springBounciness = 10
        positionAnimation.completionBlock = {(anim, finished) -> Void in
            transitionContext.completeTransition(true)
            if let block = self.completionBlock {
                block()
            }
        }
        toView.layer.pop_add(positionAnimation, forKey: "positionAnimation")
    }

}

class NavPopoverPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate var offsetY: CGFloat
    fileprivate var contentHeight: CGFloat
    
    init(offsetY: CGFloat, contentHeight: CGFloat) {
        self.offsetY = offsetY
        self.contentHeight = contentHeight
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
      guard  let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        fromView.tintAdjustmentMode = UIViewTintAdjustmentMode.dimmed
        fromView.isUserInteractionEnabled = false
        
        let dimmingView = UIView(frame: fromView.bounds)
        dimmingView.backgroundColor = UIColor.clear
        //        dimmingView.layer.opacity = 0.0
        
      guard  let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.frame = CGRect(x: screenWidth - 120 - 10, y: offsetY, width: 120, height: contentHeight)
        toView.layer.opacity = 0.0
        transitionContext.containerView.addSubview(dimmingView)
        transitionContext.containerView.addSubview(toView)
        
       guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? NavPopoverViewController else { return }
        
       guard let opacityAnimation = POPBasicAnimation(propertyNamed:kPOPLayerOpacity) else { return }
        opacityAnimation.toValue = 1.0
        opacityAnimation.completionBlock = {(anim, finished) -> Void in transitionContext.completeTransition(true)}

        toView.layer.pop_add(opacityAnimation, forKey:"opacityAnimation")
          let tap = UITapGestureRecognizer(target: toVC, action: #selector(toVC.dismiss(_:)))
        dimmingView.addGestureRecognizer(tap)
    }
}

class CellSidebarPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate var cellSidebarOffsetY: CGFloat
    fileprivate var contentHeight: CGFloat

    init(cellSidebarOffsetY: CGFloat, contentHeight: CGFloat) {
        self.cellSidebarOffsetY = cellSidebarOffsetY
        self.contentHeight = contentHeight
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
       guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        fromView.tintAdjustmentMode = UIViewTintAdjustmentMode.dimmed
        fromView.isUserInteractionEnabled = false
        
        let dimmingView = UIView(frame: fromView.bounds)
        dimmingView.backgroundColor = UIColor.clear
//        dimmingView.layer.opacity = 0.0
        
        transitionContext.containerView.tintColor = UIColor.clear
        
       guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.frame = CGRect(x: screenWidth, y: cellSidebarOffsetY, width: 150, height: contentHeight)
        transitionContext.containerView.addSubview(dimmingView)
        transitionContext.containerView.addSubview(toView)
        
       guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? NavPopoverViewController else { return }
        
        let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        positionAnimation?.toValue = screenWidth - 150 / 2
        positionAnimation?.springBounciness = 10
        positionAnimation?.completionBlock = {(anim, finished) -> Void in transitionContext.completeTransition(true)}
        
        toView.layer.pop_add(positionAnimation, forKey: "positionAnimation")
        
        let tap = UITapGestureRecognizer(target: toVC, action: #selector(toVC.dismiss(_:)))
        dimmingView.addGestureRecognizer(tap)
    }
}

class PublishNewTaskPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
      guard  let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        fromView.tintAdjustmentMode = UIViewTintAdjustmentMode.dimmed
        fromView.isUserInteractionEnabled = false
        
        //        let dimmingView = UIView(frame:fromView.bounds)
        //        dimmingView.backgroundColor = UIColor.blackColor()
        //        fromView.layer.opacity = 0.0
        
       guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        toView.center = CGPoint(x: transitionContext.containerView.center.x, y: transitionContext.containerView.center.y)
        toView.layer.opacity = 0.0
        //        transitionContext.containerView().addSubview(dimmingView)
        transitionContext.containerView.addSubview(toView)
        
        //        let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        //        positionAnimation.fromValue = NSValue(CGPoint: CGPointMake(0.01, 0.01))
        //        //        positionAnimation.toValue = 1.0
        //        positionAnimation.springBounciness = 10
        //        positionAnimation.completionBlock = {(anim, finished) -> Void in transitionContext.completeTransition(true)}
        guard let opacityAnimation = POPBasicAnimation(propertyNamed:kPOPLayerOpacity) else { return }
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 1.0
        opacityAnimation.completionBlock = {(anim, finished) -> Void in transitionContext.completeTransition(true)}
        
        toView.layer.pop_add(opacityAnimation, forKey: "opacityAnimation")
        //    [toView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"]
        //        dimmingView.layer.pop_addAnimation(opacityAnimation, forKey:"opacityAnimation")
    }
}

class ShopProductMovePresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
       guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view else { return }
        fromView.tintAdjustmentMode = UIViewTintAdjustmentMode.dimmed
        fromView.isUserInteractionEnabled = false
        
        let dimmingView = UIView(frame: fromView.bounds)
        dimmingView.backgroundColor = UIColor.black
        dimmingView.layer.opacity = 0.0
        
       guard let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else { return }
        toView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 354)
        
        transitionContext.containerView.addSubview(dimmingView)
        transitionContext.containerView.addSubview(toView)
        let opacityAnimation = POPBasicAnimation(propertyNamed:kPOPLayerOpacity)
        opacityAnimation?.fromValue = 0.0
        opacityAnimation?.toValue = 0.7
        dimmingView.layer.pop_add(opacityAnimation, forKey: "opacityAnimation")
        
        let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        positionAnimation?.toValue = screenHeight - 354 / 2
        positionAnimation?.springBounciness = 10
        positionAnimation?.completionBlock = {(anim, finished) -> Void in transitionContext.completeTransition(true)}
        toView.layer.pop_add(positionAnimation, forKey: "positionAnimation")

    }
}
