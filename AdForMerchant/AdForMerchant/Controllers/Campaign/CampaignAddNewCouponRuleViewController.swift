//
//  CampaignAddCouponRuleViewController.swift
//  AdForMerchant
//
//  Created by Kuma on 3/1/16.
//  Copyright © 2016 Windward. All rights reserved.
//

import UIKit

class CampaignAddNewCouponRuleViewController: BaseViewController {
    
    @IBOutlet weak fileprivate var totalAmountTF: UITextField!
    @IBOutlet weak fileprivate var couponAmountTF: UITextField!
    @IBOutlet weak fileprivate var confirmBtn: UIButton!
    
    var completeBlock: ((String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "设置满减规则"
        
        confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.resignAllViewFirstResponder))
        view.addGestureRecognizer(tap)
        
        totalAmountTF.addTarget(self, action: #selector(self.editingChanged(_:)), for: .editingChanged)
        couponAmountTF.addTarget(self, action: #selector(self.editingChanged(_:)), for: .editingChanged)
        
    }
}

extension CampaignAddNewCouponRuleViewController {
    func editingChanged(_ textField: UITextField) {
        textField.text = textField.text?.replacingOccurrences(of: ".", with: "")
    }
    
    func resignAllViewFirstResponder() {
        view.endEditing(false)
    }
    
    func confirmAction() {
        var total: Float = 1.0
        var coupon: Float = 0.0
        guard let totalAmount = totalAmountTF.text, !totalAmount.isEmpty else {
            Utility.showAlert(self, message: "请正确输入满金额")
            return
        }
        guard let couponAmount = couponAmountTF.text, !couponAmount.isEmpty else {
            Utility.showAlert(self, message: "请正确输入减金额")
            return
        }
        if let amount = Float(totalAmount) {
            total = amount
        }
        if let amount = Float(couponAmount) {
            coupon = amount
        }
        let min = ceilf(total * 0.05)
        let max = floorf(total * 0.5)
        
        if coupon > max || coupon < min {
            Utility.showAlert(self, message:  String(format: "减的金额只能为%.0f-%.0f元之间的整数", min, max))
            return
        }
        
        if let block = completeBlock {
            block(totalAmount, couponAmount)
        }
        _ = navigationController?.popViewController(animated: true)
        
    }
}
