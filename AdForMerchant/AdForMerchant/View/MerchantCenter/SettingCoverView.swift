//
//  WantCollectViewController.swift
//  AdForMerchant
//
//  Created by Tzzzzz on 16/10/14.
//  Copyright © 2016年 Burning. All rights reserved.
//

import UIKit
typealias BlockEdit = () -> Void
typealias BlockDelete = () -> Void

class SettingCoverView: UIView {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    var deleteBlock: BlockDelete?
    var editBlock: BlockEdit?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        editButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
   func dissmiss() {
        removeFromSuperview()
    }

    @IBAction func editHandle(_ sender: AnyObject) {
        if let block = editBlock {
            block()
        }
    }
    @IBAction func deleteHandle(_ sender: AnyObject) {
        if let block = deleteBlock {
            block()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dissmiss()
    }
}
