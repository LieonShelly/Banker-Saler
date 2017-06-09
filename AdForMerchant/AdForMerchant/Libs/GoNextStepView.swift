//
//  StepView.swift
//  Utils
//
//  Created by 李林哲 on 16/4/25.
//  Copyright © 2016年 lilinzhe. All rights reserved.
//  swiftlint:disable weak_delegate

import UIKit

protocol GoNextOrPreviousStep {
    func goNextOrPrevious(next: Bool)
}

class GoNextStepView: UIView {
    
    var delegate: GoNextOrPreviousStep?
    
    var previousBtnWidthConstr: NSLayoutConstraint!
    
    fileprivate let previousStepBtn = UIButton(type: .custom)
    fileprivate let nextStepBtn = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        userInteractionEnabled = false
        
        initialViews()
    }
    
    var animateOnlyNextStep: Bool = true {
        didSet {
            if animateOnlyNextStep {
                UIView.animate(withDuration: 0.2, animations: {
                    self.previousBtnWidthConstr.constant = 0
                    self.layoutIfNeeded()
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    let width = floor(screenWidth * 3 / 8)
                    self.previousBtnWidthConstr.constant = width
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    var previousStepButtonTitle: String? {
        didSet {
            previousStepBtn.setTitle(previousStepButtonTitle, for: UIControlState())
        }
    }
    
    var nextStepButtonTitle: String? {
        didSet {
            nextStepBtn.setTitle(nextStepButtonTitle, for: UIControlState())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        
        super.init(coder: aDecoder)
        
        initialViews()
    }

    fileprivate func initialViews() {
        
        for button in [previousStepBtn, nextStepBtn] {
            button.translatesAutoresizingMaskIntoConstraints = false
            
        }
        
        previousStepBtn.addTarget(self, action: #selector(self.goPreviousStep), for: UIControlEvents.touchUpInside)
        previousStepBtn.setTitle("上一步", for: UIControlState())
        previousStepBtn.backgroundColor = UIColor.white
        previousStepBtn.setTitleColor(UIColor.colorWithHex("0B86EE"), for: UIControlState())
        
        nextStepBtn.addTarget(self, action: #selector(self.goNextStep), for: UIControlEvents.touchUpInside)
        nextStepBtn.setTitle("下一步", for: UIControlState())
        nextStepBtn.backgroundColor = UIColor.colorWithHex("0B86EE")
        nextStepBtn.setTitleColor(UIColor.white, for: UIControlState())
        
        addSubview(previousStepBtn)
        addSubview(nextStepBtn)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(0)-[button1]-(0)-[button2]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button1": previousStepBtn, "button2": nextStepBtn]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[button1]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button1": previousStepBtn]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[button2]-(0)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["button2": nextStepBtn]))
        
        addConstraint(NSLayoutConstraint(item: previousStepBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: nextStepBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0))
        
        previousBtnWidthConstr = NSLayoutConstraint(item: previousStepBtn, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 0)
        addConstraint(previousBtnWidthConstr)
        
    }
    
    internal func goPreviousStep() {
        delegate?.goNextOrPrevious(next: false)
    }
    
    internal func goNextStep() {
        delegate?.goNextOrPrevious(next: true)
    }
    
}
