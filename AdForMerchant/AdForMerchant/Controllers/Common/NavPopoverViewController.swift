//
//  NavPopoverViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/10/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class NavPopoverViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var itemInfos: [(String, String)]!
    var offsetY: CGFloat = 40
    
    var selectItemCompletionBlock: ((Int) -> Void)?
    
    let sectionTag = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 8 + CGFloat(itemInfos.count) * 45))
        bgView.isUserInteractionEnabled = true
        bgView.image = UIImage(named: "BgBoxDown")?.stretchableImage(withLeftCapWidth: 20, topCapHeight: 20)
        view.addSubview(bgView)
        for (index, (img, name)) in itemInfos.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = sectionTag * index
            btn.addTarget(self, action: #selector(self.selectBtnAction(_:)), for: .touchUpInside)
            btn.frame = CGRect(x: 0, y: 8 + 45 * CGFloat(index), width: bgView.frame.width, height: 45)
            bgView.addSubview(btn)
            
            let imgView = UIImageView(frame: CGRect(x: 20, y: (45 - 20) / 2, width: 20, height: 20))
            imgView.contentMode = .center
            imgView.image = UIImage(named: img)
            btn.addSubview(imgView)
            
            let lbl = UILabel(frame: CGRect(x: 54, y: (45 - 20) / 2, width: bgView.frame.width - 54, height: 20))
            lbl.font = UIFont.systemFont(ofSize: 14.0)
            lbl.textColor = UIColor.white
            lbl.text = name
            btn.addSubview(lbl)
            
            if index != itemInfos.count - 1 {
                let separatorLine = SeparatorLine(frame: CGRect(x: 0, y: 45, width: bgView.frame.width, height: 0.5))
                separatorLine.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                btn.addSubview(separatorLine)
            }
        }
    }
}

extension NavPopoverViewController {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavPopoverPresentingAnimator(offsetY: offsetY, contentHeight: 8 + CGFloat(itemInfos.count) * 45)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavPopoverDismissingAnimator()
    }
    
    func dismissWithSelectedIndex(_ index: Int = -1) {
        
        self.dismiss(animated: true) { () -> Void in
            if index >= 0 {
                guard let block = self.selectItemCompletionBlock else {
                    return
                }
                block(index)
            }
        }
    }
    
    func dismiss(_ sender: AnyObject) {
        dismissWithSelectedIndex()
    }
    
    func selectBtnAction(_ sender: UIButton) {
        let index = sender.tag / sectionTag
        
        dismissWithSelectedIndex(index)
    }
}
