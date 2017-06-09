//
//  MyShopAssistantDefaultView.swift
//  AdForMerchant
//
//  Created by lieon on 2016/10/18.
//  Copyright © 2016年 Windward. All rights reserved.
//

import UIKit

class MyShopAssistantDefaultView: UIView {

    var tapAction: (() -> Void)?
    @IBAction func addButtonClick(_ sender: AnyObject) {
        if !kApp.pleaseAttestationAction(showAlert: true, type: .myShopAssistanManage) {
            return
        }
        if let block = tapAction {
            block()
        }
    }
    
}

extension MyShopAssistantDefaultView {
    class func defaultView() -> MyShopAssistantDefaultView {
        guard let view = Bundle.main.loadNibNamed("MyShopAssistantDefaultView", owner: nil, options: nil)?.first, let contentView = view as? MyShopAssistantDefaultView  else { return MyShopAssistantDefaultView() }
        return contentView
    }
}
