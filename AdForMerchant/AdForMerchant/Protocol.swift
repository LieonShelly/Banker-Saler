//
//  Protocol.swift
//  AdForMerchant
//
//  Created by lieon on 2017/2/21.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit

protocol ViewNameReusable: class { }

extension ViewNameReusable where Self: UIView {
    static var reuseIndentifier: String {
        return String(describing: self)
    }
}
