//
//  PublishHomeViewController.swift
//  FPTrade
//
//  Created by Apple on 15/9/9.
//  Copyright (c) 2015年 Windward. All rights reserved.
//

import UIKit
import pop

class AddNewObjectViewController: UIViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet fileprivate weak var bgView: UIView!
    
    internal var dismissBtnCenter: CGPoint!
    
    fileprivate var dismissBtn: UIButton!
    
    fileprivate let sectionTag: Int = 100
    fileprivate let sectionButtonTag: Int = 1
    fileprivate let sectionImageTag: Int = 2
    fileprivate let sectionLabelTag: Int = 3
    fileprivate let sectionDetailLabelTag: Int = 4
    
    var objectInfos: [(String, String?, String)]!
    
    var sectionViews: [(UIButton, UIImageView)] = []
    
    var selectItemCompletionBlock: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ges = UITapGestureRecognizer(target: self, action: #selector(AddNewObjectViewController.dismissPublishHome))
        self.view.addGestureRecognizer(ges)
        
        dismissBtn = UIButton(type: .custom)
        dismissBtn.setImage(UIImage(named: "BtnPublishOff"), for: UIControlState())
        dismissBtn.frame = CGRect(x: 0, y: 0, width: 54, height: 54)
        dismissBtn.center = CGPoint(x: dismissBtnCenter.x, y: dismissBtnCenter.y - 20)
        dismissBtn.addTarget(self, action: #selector(AddNewObjectViewController.dismissPublishHome), for: .touchUpInside)
        bgView.addSubview(dismissBtn)
        
        var originY = dismissBtn.frame.minY - 15
        
        for (index, (name, detail, img)) in objectInfos.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = sectionTag * index + sectionButtonTag
            btn.setImage(UIImage(named: img), for: UIControlState())
            btn.addTarget(self, action: #selector(AddNewObjectViewController.selectBtnAction(_:)), for: .touchUpInside)
            bgView.addSubview(btn)
            
            let imgWidth: CGFloat = (detail == nil) ? 136 : (screenWidth - 75)
            let detailSize = (detail ?? ("" as NSString) as String).boundingRect(with: CGSize(width: imgWidth - 30, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13.0)], context: nil)
            let imgHeight: CGFloat = (detail == nil) ? 40 : (ceil(detailSize.height) + 45)
            
            originY -= imgHeight
            
            btn.frame = CGRect(x: dismissBtn.frame.minX + 2, y: originY, width: 50, height: 50)
            
            let imgView = UIImageView(frame: CGRect(x: dismissBtn.frame.maxX, y: btn.frame.minY + 5, width: imgWidth, height: imgHeight))
            imgView.tag = sectionTag * index + sectionImageTag
            imgView.isUserInteractionEnabled = true
            imgView.image = UIImage(named: "PublishTextLblBg")
            bgView.addSubview(imgView)
            
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(AddNewObjectViewController.tapImgView(_:)))
            imgView.addGestureRecognizer(tapGest)
            
            let lbl = UILabel(frame: CGRect(x: 20, y: 10, width: imgWidth - 25, height: 20))
            lbl.tag = sectionTag * index + sectionLabelTag
            lbl.font = UIFont.systemFont(ofSize: 16.0)
            lbl.textColor = UIColor.colorWithHex("494A4D")
            lbl.text = name
            imgView.addSubview(lbl)
            
            if detail != nil {
                let detailLbl = UILabel(frame: CGRect(x: 20, y: lbl.frame.maxY, width: imgWidth - 30, height: ceil(detailSize.height)))
                detailLbl.tag = sectionTag * index + sectionDetailLabelTag
                detailLbl.font = UIFont.systemFont(ofSize: 13.0)
                detailLbl.numberOfLines = 0
                detailLbl.textColor = UIColor.commonGrayTxtColor()
                detailLbl.text = detail
                imgView.addSubview(detailLbl)
            }
            
            sectionViews.append((btn, imgView))
            
            btn.layer.opacity = 0.0
            imgView.layer.opacity = 0.0
            
            originY -= 20
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let rotateAnimation = POPBasicAnimation(propertyNamed:kPOPLayerRotation)
        rotateAnimation?.toValue = .pi * 0.25
        rotateAnimation?.duration = 0.15
        dismissBtn.layer.pop_add(rotateAnimation, forKey: "rotateAnimation")
        
        for (btn, imgView) in sectionViews {
            var btnFrame = btn.frame
            btnFrame.origin.y += 100
            btn.frame = btnFrame
            var imgFrame = imgView.frame
            imgFrame.origin.y += 100
            imgView.frame = imgFrame
        }
        
        for (index, (btn, imgView)) in sectionViews.enumerated() {
            
            let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            positionAnimation?.toValue = btn.frame.midY - 100
            positionAnimation?.springBounciness = 10
            positionAnimation?.beginTime = CACurrentMediaTime() + 0.04 * Double(index)
            let opacityAnimation = POPBasicAnimation(propertyNamed:kPOPLayerOpacity)
            opacityAnimation?.toValue = 1.0
            opacityAnimation?.beginTime = CACurrentMediaTime() + 0.04 * Double(index)
            
            let positionAnimation2 = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            positionAnimation2?.toValue = imgView.frame.midY - 100
            positionAnimation2?.springBounciness = 10
            positionAnimation2?.beginTime = CACurrentMediaTime() + 0.04 * Double(index)
            
            btn.layer.pop_add(positionAnimation, forKey: "positionAnimation")
            btn.layer.pop_add(opacityAnimation, forKey: "opacityAnimation")
            imgView.layer.pop_add(positionAnimation2, forKey: "positionAnimation2")
            imgView.layer.pop_add(opacityAnimation, forKey: "opacityAnimation2")
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AddNewObjectViewController {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PublishNewTaskPresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PublishNewTaskDismissingAnimator()
    }
    
    func dismissPublishView(_ index: Int = -1) {
        
        let rotateAnimation = POPBasicAnimation(propertyNamed:kPOPLayerRotation)
        rotateAnimation?.toValue = 0
        rotateAnimation?.duration = 0.15
        dismissBtn.layer.pop_add(rotateAnimation, forKey: "rotateAnimation")
        
        self.dismiss(animated: true) { () -> Void in
            if index >= 0 {
                guard let block = self.selectItemCompletionBlock else {
                    return
                }
                block(index)
            }
        }
    }
    
    func dismissPublishHome() {
        dismissPublishView()
    }
    
    func tapImgView(_ tap: UITapGestureRecognizer) {
        guard let imgView = tap.view else { return }
        let index = imgView.tag / sectionTag
        dismissPublishView(index)
    }
    
    func selectBtnAction(_ sender: UIButton) {
        let index = sender.tag / sectionTag
        
        dismissPublishView(index)
    }
}
