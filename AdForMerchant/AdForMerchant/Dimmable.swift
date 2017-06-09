//
//  Dimmable.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable type_name
// swiftlint:disable identifier_name

import UIKit

enum Direction { case `in`, out }

protocol Dimmable {
    func dim(_ direction: Direction, coverNavigationBar: Bool)
}

let dimViewTag = 1997

extension UIViewController: Dimmable {
    func dim(_ direction: Direction, coverNavigationBar: Bool = false) {
        let color = UIColor.black
        let alpha: CGFloat = 0.5
        let speed: Double = 0.5
        
        switch direction {
        case .in:
            
            // Create and add a dim view
            let dimView: UIView
            if coverNavigationBar == true {
                dimView = UIView(frame: UIScreen.main.bounds)
                dimView.backgroundColor = color
                dimView.alpha = 0.0
                dimView.tag = dimViewTag
                navigationController?.view.addSubview(dimView)
                // Deal with Auto Layout
                dimView.translatesAutoresizingMaskIntoConstraints = false
                navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
                navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
                
                // Animate alpha (the actual "dimming" effect)
                UIView.animate(withDuration: speed, animations: { () -> Void in
                    dimView.alpha = alpha
                }) 
            } else {
                dimView = UIView(frame: view.frame)
                dimView.backgroundColor = color
                dimView.alpha = 0.0
                dimView.tag = dimViewTag
                view.addSubview(dimView)
                // Deal with Auto Layout
                dimView.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
                
                // Animate alpha (the actual "dimming" effect)
                UIView.animate(withDuration: speed, animations: { () -> Void in
                    dimView.alpha = alpha
                }) 
            }
        case .out:
            if coverNavigationBar == true {
                let dim = self.navigationController?.view.viewWithTag(dimViewTag)
                UIView.animate(withDuration: speed, animations: {
                    dim?.alpha = alpha 
                    }, completion: { (complete) -> Void in
                        dim?.removeFromSuperview()
                })
            } else {
                let dim = view.viewWithTag(dimViewTag)
                UIView.animate(withDuration: speed, animations: {
                    dim?.alpha = alpha 
                    }, completion: { (complete) -> Void in
                        dim?.removeFromSuperview()
                })
            }
        }
    }
}
