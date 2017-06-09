//
//  ShowDatePickerView.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/14.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
typealias BlockConfirm = () -> Void
typealias BlockCancel = () -> Void

class ShowDatePickerView: UIView {
    var confirmBlock: BlockConfirm?
    var cancelBlock: BlockCancel?
    @IBOutlet weak var datePickerView: DVYearMonthDatePicker!
    
    @IBAction func cancelHandel(_ sender: Any) {
        guard let block = cancelBlock else {return}
        block()
    }
    @IBAction func confirmHandle(_ sender: Any) {
        guard let block = confirmBlock else {return}
        block()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
