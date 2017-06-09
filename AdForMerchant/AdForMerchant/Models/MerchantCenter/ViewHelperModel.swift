//
//  ViewHelperModel.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/26.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class SetItemCodeViewHelpModel: NSObject {
    var desc: String?
    var titleValue: String?
    var title: String?
    convenience init(desc: String, titleValue: String, title: String? = nil) {
        self.init()
        self.desc = desc
        self.titleValue = titleValue
        self.title = title
    }
}

class SetItemCatViewHelpModel: NSObject {
    var title: String?
    var subTitle: String?
    var selectedRowAction: (() -> Void)?
    
    convenience init(title: String, subTitle: String, selectedtAction: @escaping (() -> Void)) {
        self.init()
        self.title = title
        self.subTitle = subTitle
        self.selectedRowAction = selectedtAction
    }
}
