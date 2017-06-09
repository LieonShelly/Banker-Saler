//
//  StepPageControl.swift
//  AdForMerchant
//
//  Created by Kuma on 6/6/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

public let screenW = UIScreen.main.bounds.size.width

let selectedIndexBgColor = UIColor.colorWithHex("0B86EE")
let selectedIndexColor = UIColor.white
let selectedTitleColor = UIColor.colorWithHex("0B86EE")

let normalIndexBgColor = UIColor.colorWithHex("E0E5E9")
let normalIndexColor = UIColor.colorWithHex("949599")
let normalTitleColor = UIColor.colorWithHex("9BA8B4")

private class StepSubView: UIView {
    
    /// step索引值
    var stepIndex: Int = 0
    
    ///标题字体
    var stepTitleFont = UIFont.systemFont(ofSize: 13) {
        didSet {
            stepTitleLabel.font = stepTitleFont
        }
    }
    
    ///step标题文本
    var stepTitle: String = "" {
        didSet {
            stepTitleLabel.text = stepTitle
            let x: CGFloat = 10
            let y: CGFloat = stepBtn.frame.maxY + 5
            let width: CGFloat = frame.size.width - 20
            let height: CGFloat = frame.size.height - y - 10
            stepTitleLabel.frame = CGRect(x: x, y: y, width: width, height: height)
            stepTitleLabel.textAlignment = .center
            
        }
    }
    
    ///stepIndex 字体
    var stepIndexFont: UIFont! {
        didSet {
            let offset: CGFloat = 5
            let width = stepIndexFont.pointSize + offset * 2
            let x = frame.width * 0.5 - width * 0.5
            let y = frame.height * 0.2
            stepBtn.frame = CGRect(x: x, y: y, width: width, height: width)
            stepBtn.layer.cornerRadius = stepIndexFont.pointSize * 0.5 + offset
            stepBtn.titleLabel?.font = stepIndexFont
        }
    }
    
    ///stepSubView点击Block
    var stepBtnClickBack: ((_ index: Int) -> Void)?
    
    var stepBtn = UIButton()
    var stepTitleLabel = UILabel()
    
    ///初始化控件
    
    func initializer() {
        
        stepBtn.setTitleColor(normalIndexColor, for: UIControlState())
        stepBtn.setTitleColor(selectedIndexColor, for: .selected)
        stepBtn.setBackgroundImage(createImageWithColor(normalIndexBgColor), for: UIControlState())
        stepBtn.setBackgroundImage(createImageWithColor(selectedIndexBgColor), for: .selected)
        stepBtn.clipsToBounds = true
        stepBtn.isUserInteractionEnabled = false
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.stepSubViewClickAction))
        self.addGestureRecognizer(tapGR)
        addSubview(stepTitleLabel)
        addSubview(stepBtn)
        
    }
    
    @objc func stepSubViewClickAction() {
        stepBtn.isSelected = true
        if let b = stepBtnClickBack {
            b(stepIndex)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateUI()
    }
    
    func createImageWithColor(_ color: UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return  UIImage()}
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage ?? UIImage()
    }
    
    func updateUI() {
        
        stepBtn.setTitle(String(stepIndex + 1), for: UIControlState())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class StepPageControl: UIView {
    
    ///setpSubViews数组
    fileprivate var stepSubViews: [StepSubView] = []
    
    ///是否拥有点击事件
    var canClick  = false {
        didSet {
            self.isUserInteractionEnabled = canClick
        }
    }
    var lineView: UIView?
    ///中间线的高度
    var lineHeight: CGFloat = 0.5
    
    ///中间线的颜色
    var lineColor = UIColor.lightGray
    
    ///subView的点击事件，返回相应的index

    var subViewClickBlock: ((_ index: Int) -> Void)?

    ///步骤视图的标题数组
    var stepTitleArray: [String] = [] {
        didSet {
            //移除原来存在的视图
            for view in stepSubViews {
                view.removeFromSuperview()
            }
            stepSubViews.removeAll()
            
            //新建 stepSubView
            let subW = frame.size.width/CGFloat(stepTitleArray.count)
            for (index, stepTitle) in stepTitleArray.enumerated() {
                
                let sx = subW * CGFloat(index)
                let swidth = subW
                let sheight = frame.size.height
                
                let stepSubView = StepSubView(frame: CGRect(x: sx, y: 0, width: swidth, height: sheight))
                /**************这里可以设置 stepSubView的相关属性*************/
                stepSubView.stepIndex = index
                stepSubView.stepIndexFont = UIFont(name: "Futura-CondensedMedium", size: 20) ??
                    UIFont.systemFont(ofSize: 20)
                stepSubView.stepTitle = stepTitle
                stepSubView.stepTitleFont = UIFont.systemFont(ofSize: 12)
                
                stepSubView.updateUI()
                stepSubView.stepBtnClickBack = {(index) in
                    
                    if let c = self.subViewClickBlock {
                        self.selectSubVeiwByIndex(index)
                        c(index)
                    }
                }
                
                addSubview(stepSubView)
                stepSubViews.append(stepSubView)
            }
            
            let lineX: CGFloat = stepSubViews[0].center.x
            let lineY: CGFloat = stepSubViews[0].stepBtn.center.y - lineHeight * 0.5
            let lineW: CGFloat = stepSubViews[stepSubViews.count-1].center.x - lineX
            let lineH: CGFloat = lineHeight
            let lineView = UIView(frame: CGRect(x: lineX, y: lineY, width: lineW, height: lineH))
            self.lineView = lineView
            lineView.backgroundColor = lineColor
            self.addSubview(lineView)
            self.sendSubview(toBack: lineView)
            selectSubVeiwByIndex(0)
        }
    }
    
    ///选中某个 子视图
    func selectSubVeiwByIndex(_ index: Int) {
        
        if index >= self.stepSubViews.count {
//            print("index 非法！")
            return
        }
        stepSubViews[index].stepBtn.isSelected = true
        stepSubViews[index].stepTitleLabel.textColor = selectedTitleColor
        
        for (i, stepsubview) in stepSubViews.enumerated() {
            if i != index {
                stepsubview.stepBtn.isSelected = false
                stepsubview.stepTitleLabel.textColor = normalTitleColor
            }
            stepsubview.updateUI()
        }
    }
    
    func showDashLine() {
        guard let view = lineView else { return }
        view.backgroundColor = UIColor.clear
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.lineDashPattern = [4, 2]
        let path = CGMutablePath()
        path.addLines(between: [CGPoint.zero,
                                CGPoint(x: view.frame.width, y: 0)])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
