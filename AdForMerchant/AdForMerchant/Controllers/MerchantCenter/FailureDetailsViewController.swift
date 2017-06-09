//
//  FailureDetailsViewController.swift
//  AdForMerchant
//
//  Created by 糖otk on 2017/2/23.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit

class FailureDetailsViewController: BaseViewController {

    lazy var headLabel: UILabel = {
        let headLabel = UILabel(frame: CGRect(x: 10, y: 14, width: 100, height: 20))
        headLabel.text = "审核不通过"
        return headLabel
    }()
    
    lazy var lineView: UIView = {
        let lineView = UIView(frame: CGRect(x: 10, y: 45, width: screenWidth-20, height: 1))
        lineView.backgroundColor = UIColor.colorWithHex("e4e5f2")
        return lineView
    }()
    
    lazy var errorLabel: UILabel = {
        let errorLabel = UILabel(frame: CGRect(x: 10, y: 60, width: screenWidth-20, height: 0))
        errorLabel.textColor = UIColor.colorWithHex("9498a9")
        errorLabel.numberOfLines = 0
        return errorLabel
    }()
    
    lazy var underView: UIView = {
        let underView = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0))
        underView.backgroundColor = UIColor.colorWithHex("f5f5f5")
        return underView
    }()
    
    var errorMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func setupUI() {
        title = "商户认证"
        view.backgroundColor = UIColor.white
        view.addSubview(self.headLabel)
        view.addSubview(self.lineView)
        view.addSubview(self.errorLabel)
        view.addSubview(self.underView)
        let attriText = self.getAttributeStringWithString(errorMessage, lineSpace: 5.00)
         let height = String.getLabHeigh(attriText.string, font: UIFont.systemFont(ofSize: 17), width: screenWidth-20)
        errorLabel.height = height+30
        errorLabel.attributedText = attriText
        underView.y = errorLabel.y+errorLabel.height
        underView.height = screenHeight - underView.y
    }
    
    fileprivate func getAttributeStringWithString(_ string: String, lineSpace: CGFloat
        ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        let paragraphStye = NSMutableParagraphStyle()
        
        //调整行间距
        paragraphStye.lineSpacing = lineSpace
        let rang = NSRange(location: 0, length: CFStringGetLength(string as CFString!))
        attributedString .addAttribute(NSParagraphStyleAttributeName, value: paragraphStye, range: rang)
        return attributedString
        
    }

}
