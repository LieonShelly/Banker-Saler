//
//  EditStaffContentView.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/19.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit
import ObjectMapper

class EditStaffContentView: UIView {
    var tapAction:((_ staffModel: Staff) -> Void)?
    var helpAction: (() -> Void)?
    var  staffModel: Staff? {
        didSet {
            roleTextField.text = staffModel?.limits.title
            nameTextField.text = staffModel?.name
            numTextField.text = staffModel?.mobile
            nameTextField.becomeFirstResponder()
        }
    }
    var staffID: String? {
        didSet {
            self.requestData()
        }
    }
    
    @IBOutlet weak var roleTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var numTextField: UITextField!
    
    @IBAction func helpButtonClick(_ sender: AnyObject) {
        if let block = helpAction {
            block()
        }
    }

    @IBAction func enterButtonClick(_ sender: AnyObject) {
         guard let staff = staffModel else { return  }
        staff.name = nameTextField.text
        staff.mobile = numTextField.text
        staff.limits.title = roleTextField.text
        if let block = tapAction {
            block(staff)
        }
    }
    
    func requestData() {
        Utility.showMBProgressHUDWithTxt()
        let params: [String: Any] = ["staff_id": staffID ?? ""]
        let aesKey = AFMRequest.randomStringWithLength16()
        let aesIV = AFMRequest.randomStringWithLength16()
        
        RequestManager.request(AFMRequest.detailsStaff(params, aesKey, aesIV), aesKeyAndIv: (aesKey, aesIV)) { (_, _, object, error, msg) -> Void in
            if let result = object as? [String: Any] {
                guard let info = Mapper<Staff>().map(JSON: result) else {return}
                self.nameTextField.text = info.name
                self.numTextField.text = info.mobile
                self.roleTextField.text = info.limits.title
                Utility.hideMBProgressHUD()
            } else {
                Utility.hideMBProgressHUD()
            }
        }
    }

}

extension EditStaffContentView {
    class func contentView() -> EditStaffContentView {
        guard let view = Bundle.main.loadNibNamed("EditStaffContentView", owner: nil, options: nil)?.first, let contentView = view as? EditStaffContentView  else { return EditStaffContentView() }
        return contentView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}
