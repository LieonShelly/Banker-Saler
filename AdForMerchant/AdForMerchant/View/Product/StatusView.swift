//
//  StatusView.swift
//  AdForMerchant
//
//  Created by lieon on 2017/2/22.
//  Copyright © 2017年 Windward. All rights reserved.
//

import UIKit

class StatusView: UIView {
    @IBOutlet weak var reasonLabel: UILabel!
    
    func congfig(status: StatusDetail) {
        reasonLabel.text = status.remark
    }
    
    static func detailView() -> StatusView {
        guard let view = Bundle.main.loadNibNamed("StatusView", owner: nil, options: nil)?.first as? StatusView else { return  StatusView()}
        return view
    }

}
