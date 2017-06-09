//
//  FPTAlertViewController.swift
//  FPTrade
//
//  Created by Kuma on 9/8/15.
//  Copyright (c) 2015 Windward. All rights reserved.
//

import UIKit

class DoMoreBarViewController: UIViewController {
    
    var buttonAvailablities: [Bool] = [true, true, true, true]
    var buttonTitles: [String] = ["预览", "下架", "分享", "返回"]
    var buttonImages: [String] = ["CellSidebarIconPreview", "CellSidebarIconOffShelf", "CellSidebarIconShare", "CellSidebarIconBack"]
    var cellSidebarOffsetY: CGFloat = 0
    var contentHeight: CGFloat = 0
    
    var selectItemCompletionBlock: ((Int) -> Void)?
    
    let itemButtonBaseTag = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.tintColor = UIColor.clear
        view.clipsToBounds = true
        addViews()
    }
}

extension DoMoreBarViewController {
    func addViews() {
        let mainContentBg = UIView()
        mainContentBg.backgroundColor = UIColor.white
        mainContentBg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContentBg)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[mainContentBg]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["mainContentBg": mainContentBg]) )
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[mainContentBg]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["mainContentBg": mainContentBg]) )
        
        let button1 = UIButton(type: .custom)
        let button2 = UIButton(type: .custom)
        let button3 = UIButton(type: .custom)
        let button4 = UIButton(type: .custom)
        
        for (index, button) in [button1, button2, button3, button4].enumerated() {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = itemButtonBaseTag + index
            button.backgroundColor = UIColor.colorWithHex("88ABDA")
            button.addTarget(self, action: #selector(DoMoreBarViewController.confirm(_:)), for: UIControlEvents.touchUpInside)
            button.isEnabled = buttonAvailablities[index]
        }
        
        mainContentBg.addSubview(button1)
        mainContentBg.addSubview(button2)
        mainContentBg.addSubview(button3)
        mainContentBg.addSubview(button4)
        
        mainContentBg.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[button1]-(0.5)-[button2]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button1": button1, "button2": button2]))
        mainContentBg.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[button3]-(0.5)-[button4]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button3": button3, "button4": button4]))
        
        mainContentBg.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[button1]-(0.5)-[button3]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button1": button1, "button3": button3]))
        mainContentBg.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[button2]-(0.5)-[button4]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button2": button2, "button4": button4]))
        
        mainContentBg.addConstraint(NSLayoutConstraint(item: button1, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: button2, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0))
        mainContentBg.addConstraint(NSLayoutConstraint(item: button1, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: button3, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0))
        mainContentBg.addConstraint(NSLayoutConstraint(item: button1, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: button4, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0))
        mainContentBg.addConstraint(NSLayoutConstraint(item: button1, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: button2, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0))
        mainContentBg.addConstraint(NSLayoutConstraint(item: button1, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: button3, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0))
        mainContentBg.addConstraint(NSLayoutConstraint(item: button1, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: button4, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0))
        
        for (index, button) in [button1, button2, button3, button4].enumerated() {
            let imgView = UIImageView(frame: CGRect(x: 11, y: contentHeight / 4 - 25, width: 55, height: 30))
            imgView.image = UIImage(named: buttonImages[index])
            imgView.contentMode = .center
            button.addSubview(imgView)
            
            let titleLbl = UILabel(frame: CGRect(x: 11, y: contentHeight / 4 + 5, width: 55, height: 20))
            titleLbl.text = buttonTitles[index]
            titleLbl.textAlignment = .center
            titleLbl.font = UIFont.systemFont(ofSize: 14.0)
            titleLbl.textColor = UIColor.colorWithHex("FFFFFF")
            button.addSubview(titleLbl)
            
            if !buttonAvailablities[index] {
                imgView.tintColor = UIColor.commonGrayTxtColor()
                imgView.image = UIImage(named: buttonImages[index])?.withRenderingMode(.alwaysTemplate)
                titleLbl.textColor = UIColor.commonGrayTxtColor()
            }
        }
    }
    
    func confirm(_ sender: UIButton) {
        let index = sender.tag - itemButtonBaseTag
        self.dismiss(animated: true, completion: { () -> Void in
            if index >= 0 {
                guard let block = self.selectItemCompletionBlock else {
                    return
                }
                block(index)
            }
        })
    }
    
    func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
}

extension DoMoreBarViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CellSidebarPresentingAnimator(cellSidebarOffsetY: cellSidebarOffsetY, contentHeight: contentHeight)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CellSidebarDismissingAnimator()
    }

}
